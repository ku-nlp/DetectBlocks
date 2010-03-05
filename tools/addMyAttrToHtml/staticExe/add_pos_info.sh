#!/usr/bin/env zsh

# $Id$

# Usage : zsh $0 Agaricus 052 Agaricus
# for   : timeout�����ꤷ�Ƽ��եڡ����˰��־������Ϳ���륹����ץ�

source $HOME/.zshrc

orig_dir=$HOME/DetectSender/htmls/100122   # �� ���ѹ� : wget����original�Υǥ��쥯�ȥ�           ��
result_dir=$HOME/DetectSender/htmls/100129 # �� ���ѹ� : ���־������Ϳ������̤��ݤ��ǥ��쥯�ȥ� ��
DetectBlocks=/home/funayama/DetectBlocks   # �� ���ѹ� : DetectBlocks�Υǥ��쥯�ȥ�               ��

script=$DetectBlocks/tools/addMyAttrToHtml/staticExe/wkhtmltopdf-reed

topic_first=$1
id_first=$2
flag=1

topic1=$3

logfile=$DetectBlocks/tools/addMyAttrToHtml/staticExe/add_pos_info-$topic1.log

# ������ָ��timeout����ؿ�
timeout()
{
    count_timeout=$1
    shift 1;
    # echo exec \'$@\'
    $@ &
    pid=$!
    count=0
    while [ $count -lt $count_timeout ]
    do
	isalive=`ps -ef | grep $pid | grep -v grep | wc -l`
	if [ $isalive -eq 1 ]; then
	    echo $pid is alive ($count).
	    count=`expr $count + 1`
	    sleep 1
	else
	    echo $pid was disappeared.
	    count=`expr $count_timeout + 1`
	fi
    done
    isalive=`ps -ef | grep $pid | grep -v grep | wc -l`
    if [ $isalive -eq 1 ]; then
	kill -9 $pid
	# wait $pid
	echo TIMEOUT \'$@\'
	echo $pid was terminated by a SIG$(kill -l $?) signal.
    fi
    echo func timeout end.
}

for d in $orig_dir/*;do

    if [ "$d" = "$orig_dir/$topic1" ];then

	if [ ! -d $d ];then
	    continue
	fi
	for id in $d/*;do
	    if [ ! -d $id ];then
		continue
	    fi
	    echo '======' >> $logfile
	    echo $id  >> $logfile
	    echo $id

	    if [ $flag = 1 ];then
		if [ "$d" = "$orig_dir/$topic_first" -a "$id" = "$orig_dir/$topic_first/$id_first" ]; then
		    flag=0
		else 
		    echo NEXT
		    continue
		fi
	    fi

	    for file in $id/**/*.meta; do
	        # /home/funayama/DetectSender/htmls/100122/Agaricus/001/index.html.meta
		echo "  $file" >> $logfile
		echo "  $file"

	        # /home/funayama/DetectSender/htmls/100122/Agaricus/001/index.html
		orig_filepath=$file:r

		if [ ! -f $orig_filepath ];then
		    echo $orig_filepath not Found. >> $logfile
		    echo $orig_filepath not Found.
		    continue
		fi

	        # index.html
		orig_filename=$orig_filepath:t

	        # /home/funayama/DetectSender/htmls/100122pos/Agaricus/001/index.html
		result_filename=`echo $orig_filepath | sed -e "s/100122/100129/"`

	        # /home/funayama/DetectSender/htmls/100122pos/Agaricus/001
		result_dirname=`dirname $result_filename`
		
	        # ��̤��ݤ��ǥ��쥯�ȥ�
		if [ ! -d $result_dirname ];then
		    mkdir -p $result_dirname
		fi

	        # /home/funayama/tmp/index.html.8655
		tmpfile=$HOME/tmp/$$.$orig_filename

		if [ -f $tmpfile ];then
		    \rm -fr $tmpfile
		fi

	        # ���� -> ���Х��
		echo Converting ...
		nice -10 perl -I$DetectBlocks/perl $DetectBlocks/tools/addMyAttrToHtml/staticExe/ConvCSS_rel2abs.perl $orig_filepath > $tmpfile
		echo Done.

	        # ���ޥ�ɼ¹�
		timeout 20 $script $tmpfile $result_filename

		if [ ! -f $result_filename ];then
		    continue
		fi

		echo nkf
		timeout 3 nkf -w --overwrite $result_filename

	        # meta�ե�����򥳥ԡ�
		echo cp meta file
		cp -r -i $file $result_dirname
		\rm -fr $tmpfile
	    done
	done
    fi
done
