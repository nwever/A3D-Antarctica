# Load the settings for Alpine3D
source a3d_settings.txt

# Determine start time for meteo data
offset_hrs=${meteo_buffer}	# Start/end meteo data $offset_hrs hours before/after start/end time of Alpine3D
startdate_meteo=$(echo ${startdate} | \
	awk -v offset=${offset_hrs} '{ \
		t1=mktime(sprintf("%04d %02d %02d %02d %02d %02d 0", substr($1,1,4), substr($1,6,2), substr($1,9,2), substr($1,12,2), substr($1,15,2), substr($1,18,2))); \
		t1-=offset*60*60; \
		print(strftime("%Y-%m-%dT%H:%M:%S", t1)); \
	}')
# Determine end time for meteo data
enddate_meteo=$(echo ${enddate} | \
	awk -v offset=${offset_hrs} '{ \
		t1=mktime(sprintf("%04d %02d %02d %02d %02d %02d 0", substr($1,1,4), substr($1,6,2), substr($1,9,2), substr($1,12,2), substr($1,15,2), substr($1,18,2))); \
		t1+=offset*60*60; \
		print(strftime("%Y-%m-%dT%H:%M:%S", t1)); \
	}')

echo "Selecting meteo data from ${startdate_meteo} to ${enddate_meteo} ..."

# Read the meteo grid points requested for the domain
echo "[INPUT]" > ${setup_prefix}/stn.lst
i=0	# Count the stations
while read -r idx latitude longitude easting northing
do
	let i=${i}+1
	# Header
	awk '{print; if(/\[DATA\]/) {exit}}' ${meteo_smet_dir}/${latitude}_${longitude}.smet > ${meteofiles_prefix}/${latitude}_${longitude}.smet
	# Data
	awk -v t1=${startdate_meteo} -v t2=${enddate_meteo} '{if(substr($1,1,16)>=substr(t1,1,16) && substr($1,1,16)<=substr(t2,1,16)) {print}}' ${meteo_smet_dir}/${latitude}_${longitude}.smet >> ${meteofiles_prefix}/${latitude}_${longitude}.smet

	# Add meteo station to list of stations
	echo "STATION${i} = ${latitude}_${longitude}" >> ${setup_prefix}/stn.lst 
done < <(grep -v ^# "${meteofiles_prefix}meteostn.lst")
