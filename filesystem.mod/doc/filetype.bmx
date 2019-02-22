' filetype.bmx

SuperStrict

Print FileType(".")		' prints 2 for directory type
Print FileType("filetype.bmx")	' prints 1 for file type
Print FileType("notfound.file")	' prints 0 for doesn't exist
