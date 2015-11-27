

MV	= mv -f
PWD     = `pwd`
DATE 	= `date '+%Y%m%d-%H%M'`

BACKUP_DIR    = backups


TARGET_FILES =  check_connection.sh default.conf dl-sensor_data.sh \
		func_cnct_check.sh func_dl_data.sh func_save_data-log.sh \
		setup_sensor.sh start_measurement.sh stop_measurement.sh \
		test_func_dl_data.sh test_func_cnct_check.sh test_func_dl_data.sh \
		test_func_save_data-log.sh

# backup:
# 	if [ ! -d $(BACKUP_DIR) ] ;\
# 	then mkdir $(PWD)/$(BACKUP_DIR) ;\
# 	fi
# 	for TARGET in $(TARGET_FILES); do (cp $$TARGET $(BACKUP_DIR)/$$TARGET.$(DATE).bak ) done;
# 	if [ -e $ $(PWD)/*.bak ] ;\
# 	then $(MV) $(PWD)/*.bak $(PWD)/$(BACKUP_DIR)/ ;\
# 	fi

backup:
	if [ ! -d $(BACKUP_DIR) ] ;\
	then mkdir $(PWD)/$(BACKUP_DIR) ;\
	fi
	zip Sensor_${DATE}.zip ${TARGET_FILES};\
	if [ -e $ $(PWD)/*.zip ] ;\
	then $(MV) $(PWD)/*.zip $(PWD)/$(BACKUP_DIR)/ ;\
	fi

clean:
	echo "not yet"
