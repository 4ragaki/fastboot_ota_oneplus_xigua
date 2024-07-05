backupdir="backups_debloat_$(date '+%Y%m%d_%H%M%S')"
workingdir="tmp"
partitions=(
  "my_bigball" "my_heytap" "my_preload" "my_product" "my_stock"
)
reservations=(
  "Calculator2" "Calendar" "Clock"
  "ConsumerIRApp" "FileManager" "KeKeThemeSpace"
  "Melody" "NewSoundRecorder" "OppoCompass2"
  "OppoWeather2" "OppoNote2" "Shortcuts"
)


rm $workingdir -rf
mkdir $backupdir -p
mkdir $workingdir -p


echo -e "\n"
for part in ${partitions[@]}
do
  img=$part.img
  mv $img $backupdir
  echo -e "$img was backed up at $backupdir/$img"
done


for part in ${partitions[@]}
do
  target=$part.img
  img=$backupdir/$target
  part_workingdir=$workingdir/$part
  mkdir $part_workingdir -p

  echo -e "\nprocessing $target"
  extract.erofs -x -i $img -o $part_workingdir

  echo -e "\n"
  for delapp in $(find $part_workingdir -maxdepth 3 -path "*/del-app/*" -type d ); do
    app_name=$(basename ${delapp})

    reserve=false
    for reservation in "${reservations[@]}"; do
      if [[ $app_name == *"$reservation"* ]]; then
        echo "[+] reserving $delapp"
        reserve=true
        break
      fi
    done
      
    if [[ $reserve == false ]]; then
      echo "[-] debloating $delapp"
      rm -rf $delapp
    fi
  done

  echo -e "\n"
  mkfs.erofs -zlz4hc,9 --mount-point $part --fs-config-file $part_workingdir/config/${part}_fs_config --file-contexts $part_workingdir/config/${part}_file_contexts $target $part_workingdir/$part
done

rm $workingdir -rf
