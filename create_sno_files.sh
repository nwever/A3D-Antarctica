# Load the settings for Alpine3D
source a3d_settings.txt


# Read the SNOWPACK grid points requested for the domain, and create the *sno files from the SNOWPACK stand-alone *.pro files
while read -r idx latitude longitude easting northing
do
	zipfile="${latitude}_${longitude}${SNOWPACK_sims_suffix}.zip"
	unzip -p ${SNOWPACK_sims_dir}/${zipfile} "*.pro" | bash ${create_sno_from_profile_script} "/dev/stdin" ${startdate} > ${snofile_grids_prefix}/${idx}.sno
done < <(grep -v ^# ${input_grids_prefix}.lst)
