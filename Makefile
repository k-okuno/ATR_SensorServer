
MV	= mv -f
PWD     = `pwd`
DATE 	= `date '+%Y%m%d-%H%M'`
EXP_DATE = `date '+%Y%m%d'`


UNISON     = unison 
UNISON_OPT = -auto

BACKUP_DIR = backups
DEST = /e

TARGET_FILES =  check_connection.sh default.conf dl-sensor_data.sh \
		func_cnct_check.sh func_dl_data.sh func_save_data-log.sh \
		setup_sensor.sh start_measurement.sh stop_measurement.sh \
		test_func_dl_data.sh test_func_cnct_check.sh test_func_dl_data.sh \
		test_func_save_data-log.sh get_sensor_setup.sh template_get_args.sh \
		func_get_args.sh test_func_get_args.sh func_if_num.sh

backup-prog:
	if [ ! -d $(BACKUP_DIR) ] ;\
	then mkdir $(PWD)/$(BACKUP_DIR) ;\
	fi
	zip Sensor_${DATE}.zip ${TARGET_FILES};\
	if [ -e $ $(PWD)/*.zip ] ;\
	then $(MV) $(PWD)/*.zip $(PWD)/$(BACKUP_DIR)/ ;\
	fi

backup:
	if [ ! -d $(DEST) ] ;\
	then mkdir $(DEST) ;\
	fi
	rsync -Cav --append ${EXP_DATE}_DEV* ${DEST}

sync:
	$(UNISON) $(UNISON_OPT) $(PWD) /media/HDD1/$(PWD)

clean:
	$(RM) ./*~ ./*.stackdump ./*.log ./*.csv
