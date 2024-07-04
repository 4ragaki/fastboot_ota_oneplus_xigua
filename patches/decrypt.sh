backupdir="backups_decrypt_$(date '+%Y%m%d_%H%M%S')"
workingdir="tmp"
partition="vendor"
img="$partition.img"

rm $workingdir -rf
mkdir $backupdir -p
mkdir $workingdir -p

mv $img $backupdir
echo -e "\n$img was backed up at $backupdir/$img\n"

extract.erofs -x -i $backupdir/$img -o $workingdir
echo -e "\n"

for fstab in $(find $workingdir/vendor -type f -name "fstab.*");do
echo "processing target: $fstab"
sed -i "s/,fileencryption=aes-256-xts:aes-256-cts:v2+inlinecrypt_optimized+wrappedkey_v0//g" $fstab
sed -i "s/,fileencryption=aes-256-xts:aes-256-cts:v2+emmc_optimized+wrappedkey_v0//g" $fstab
sed -i "s/,fileencryption=aes-256-xts:aes-256-cts:v2//g" $fstab
sed -i "s/,metadata_encryption=aes-256-xts:wrappedkey_v0//g" $fstab
sed -i "s/,fileencryption=aes-256-xts:wrappedkey_v0//g" $fstab
sed -i "s/,metadata_encryption=aes-256-xts//g" $fstab
sed -i "s/,fileencryption=aes-256-xts//g" $fstab
sed -i "s/,fileencryption=ice//g" $fstab
sed -i "s/fileencryption/encryptable/g" $fstab
done

echo -e "\n"

mkfs.erofs -zlz4hc,9 --mount-point $partition --fs-config-file $workingdir/config/${partition}_fs_config --file-contexts $workingdir/config/${partition}_file_contexts $img $workingdir/$partition

rm $workingdir -rf
