#!/bin/bash
svn_path="https://svn.xxx.net/xxxx/xxx/xxxx"
svn_local_copy="/data/svn/xxx"
project="xxx/xxxx"
revision_from="1"
log_path="./log/"
patch_dir='./patch/'
tmp_dir='./tmp/'
remote_host='192.168.0.123'
remote_dir='/var/www/html/'

if [ ! -s "./branches" ]; then
	ln -s $svn_local_copy ./
fi

if [ ! -d $log_path ]; then
	mkdir -p $log_path
fi

if [ ! -d $patch_dir$project ]; then
	mkdir -p $patch_dir$project
fi

if [ ! -d $tmp_dir ]; then
	mkdir -p $tmp_dir
fi

if [ -f $log_path'last_revision' ]; then
	revision_from=`cat $log_path'last_revision'`
fi

svn up $project

revision_to=`svn info -r HEAD $svn_path | grep 'Changed\ Rev' | cut -b 19-`


patch_file_list=`svn log  -v -r $revision_from:$revision_to  $svn_path  | grep ' [MA] ' | awk '{printf(".%s ",$2)}'`
tar -zcpf $patch_dir$project$revision_from'_'$revision_to'.tar.gz' $patch_file_list  
#for patch_file in $patch_file_list
#do
#	echo $patch_file
#done

if [ ! -d $tmp_dir$revision_from'_'$revision_to ]; then
	mkdir -p $tmp_dir$revision_from'_'$revision_to
fi

tar -zxf $patch_dir$project$revision_from'_'$revision_to'.tar.gz' -C $tmp_dir$revision_from'_'$revision_to/

rsync -avz  $tmp_dir$revision_from'_'$revision_to/$project/* $remote_host:$remote_dir
echo $revision_to > $log_path'last_revision'
#exit
