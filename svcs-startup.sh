#!/bin/sh
. /lib/svc/share/smf_include.sh
getproparg() {
	val=`svcprop -p $1 $SMF_FMRI`
	[ -n "$val" ] && echo $val
}

BEANSTALKD_BIN=/usr/local/beanstalkd/bin
LISTEN=`getproparg beanstalkd/listen`

if [ -z $SMF_FMRI ]; then
	echo "SMF framework variables are not initialized."
	exit $SMF_EXIT_ERR
fi

if [ -z $LISTEN ]; then
        echo "varnish/listen property not set"
        exit $SMF_EXIT_ERR_CONFIG
fi

function start {
    echo "LD_LIBRARY_PATH=/usr/local/libevent/lib:/usr/local/beanstalkd/lib $BEANSTALKD_BIN/beanstalkd -l $LISTEN -p 11300 >> /usr/local/beanstalkd/logs/beanstalkd.log 2>&1 &"
    LD_LIBRARY_PATH=/usr/local/libevent/lib:/usr/local/beanstalkd/lib $BEANSTALKD_BIN/beanstalkd -l $LISTEN -p 11300 >> /usr/local/beanstalkd/logs/beanstalkd.log 2>&1 &
}

case "$1" in
  start)
    start;;
  stop)
    kill `pgrep beanstalkd` ;;
  refresh)
    kill `pgrep beanstalkd` && start;;
  *)
    echo "Usage $0 (start|stop|refresh)"
    exit 1;;
esac

exit $SMF_EXIT_OK
