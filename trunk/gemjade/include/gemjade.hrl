-record(dbOptions,
        {host,
         port=3306,
		 user,
		 password,
         database,
		 encoding}).


-record(point,
        {id,
         lon,
		 lat,
		 long_zone,
         lat_zone,
		 easting,
		 northing,
		 type}).