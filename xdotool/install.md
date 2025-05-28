#Install XdoTool from binaries
Copy all the files from the extracted .DEBs You may need to bind /etc and /usr with 


```sh
mkdir /storage/etc/
cp /etc/* /storage/etc/
mount -bind /etc /storage/etc
```
and
```sh
mkdir /storage/usr
cp /usr/* /storage/usr/
mount -bind /usr /storage/usr
```

This is often necessary because / is by default a read only file-system.