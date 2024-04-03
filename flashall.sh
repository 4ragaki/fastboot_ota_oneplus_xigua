if [ -z "${DRYRUN}" ]; then
  fastboot $* getvar product 2>&1 | grep "^product: *kalama"
  if [ $? -ne 0  ] ; then echo "Missmatching image and device"; exit 1; fi
else
  alias fastboot="echo 'fastboot$*'"
fi


fastboot set_active a

bl_partitions=(
  "boot" "dtbo" "init_boot" "vendor_boot"
)

prm_partitions=(
  "abl" "aop" "aop_config" "bluetooth" "boot" "cpucp" "devcfg" "dsp"
  "dtbo" "engineering_cdt" "featenabler" "hyp" "imagefv" "init_boot"
  "keymaster" "modem" "oplus_sec" "oplusstanvbk" "qupfw" "recovery"
  "shrm" "splash" "tz" "uefi" "uefisecapp" "vbmeta" "vbmeta_system"
  "vbmeta_vendor" "vendor_boot" "xbl" "xbl_config" "xbl_ramdump"
# "userdata" "misc"
)

lgc_partitions=(
  "my_bigball" "my_carrier" "my_company" "my_engineering" "my_heytap"
  "my_manifest" "my_preload" "my_product" "my_region" "my_stock"
  "odm" "product" "system" "system_dlkm" "system_ext" "vendor" "vendor_dlkm"
)

echo "Flashing recovery"
for part in "${bl_partitions[@]}"
do
  fastboot flash $part ${part}.img
  if [ $? -ne 0 ] ; then echo "Flash $part error"; exit 1; fi
done

fastboot flash recovery recovery.fbd.img
fastboot reboot fastboot

echo "Flashing primary partitions"
for part in "${prm_partitions[@]}"
do
  fastboot flash $part ${part}.img
  if [ $? -ne 0 ] ; then echo "Flash $part error"; exit 1; fi
done

fastboot wipe-super super_empty.img

echo "Deleting logical partitions"
for part in "${lgc_partitions[@]}"
do
  fastboot delete-logical-partition ${part}_a
  if [ $? -ne 0 ] ; then echo "Delete ${part}_a error"; exit 1; fi
  fastboot delete-logical-partition ${part}_b
  if [ $? -ne 0 ] ; then echo "Delete ${part}_b error"; exit 1; fi
done

echo "Creating logical partitions"
for part in "${lgc_partitions[@]}"
do
  fastboot create-logical-partition ${part}_a 0
  if [ $? -ne 0 ] ; then echo "Create ${part}_a error"; exit 1; fi
  fastboot create-logical-partition ${part}_b 0
  if [ $? -ne 0 ] ; then echo "Create ${part}_b error"; exit 1; fi
done

echo "Flashing logical partitions"
for part in "${lgc_partitions[@]}"
do
  fastboot flash $part ${part}.img
  if [ $? -ne 0 ] ; then echo "Flash $part error"; exit 1; fi
done

read -p "Do you wish to disable avb? (y/n) " yn
case $yn in
  [Yy]* ) echo "disabling avb";
  fastboot --disable-verity --disable-verification flash vbmeta vbmeta.img;
  fastboot --disable-verity --disable-verification flash vbmeta_system vbmeta_system.img;
  fastboot --disable-verity --disable-verification flash vbmeta_vendor vbmeta_vendor.img;;
esac

read -p "Do you wish to wipe userdata? (y/n) " yn
case $yn in
  [Yy]* ) echo "wiping userdata"; fastboot -w;;
esac

read -p "Do you wish to reboot now? (y/n) " yn
case $yn in
  [Yy]* ) echo "rebooting"; fastboot reboot;;
esac
