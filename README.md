# Apply ColorOS OTA by fastboot

## Usage

* save your working fastbootd recovery as recovery.fbd.img.

* extract my_company.img from OFP package.

`simg2img <OFP>/IMAGES/my_company/my_company.empty.img my_company.img`

* extract my_preload.img from OFP package.

`simg2img <OFP>/IMAGES/my_preload/my_preload.18682371.img my_preload.img`

* dump ColorOS OTA payload.bin here.

`payload-dumper-go payload.bin`

`mv <extracted_20240316_162638>/* .`

* reboot to bootloader.

* configure your udev rules & `./flashall.sh` or `sudo ./flashall.sh`.