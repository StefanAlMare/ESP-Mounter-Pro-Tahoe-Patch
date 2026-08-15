# Short InsanelyMac announcement

**ESP Mounter Pro 1.9.1 – macOS Tahoe 26 compatibility patch**

I have always liked **ESP Mounter Pro by Micky1979** for mounting EFI partitions, and I was sorry to see it stop working correctly on macOS Tahoe.

I found the cause and made a very small compatibility patch. Out of respect for Micky1979 and his work, I am **not redistributing ESP Mounter Pro or its helper**. The patcher modifies the user's own original ESP Mounter Pro 1.9.1 copy locally.

Tested successfully on **macOS Tahoe 26.6.1 (25G76)** on Intel/Hackintosh, with EFI partitions on internal disks, USB devices and external disks. The normal **Mount -> Open -> Unmount** behavior is restored, and normal EFI Mount/Unmount operations do not ask for the administrator password each time.

**Full explanation, source code and patcher:**  
https://github.com/StefanAlMare/ESP-Mounter-Pro-Tahoe-Patch

ESP Mounter Pro © Micky1979. All rights reserved. This is an unofficial compatibility patch only; the original application is not included.
