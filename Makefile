title := PouClone

src_folder := src/
build_folder := build/
build_web_folder := ${build_folder}web

love_file := ${title}.love
love_file_path := ${build_folder}${love_file}


clear :
	rm -R ${build_folder} || true

build : clear
	mkdir build && cd ${src_folder} && zip -9 -r ../${love_file_path} . && cd ..

web : build
	npx love.js --title ${title} -c ${love_file_path} ${build_web_folder}

serve : web
	npx serve ${build_web_folder}

run : build
	love ${love_file_path}

dev :
	love ${src_folder}
	
