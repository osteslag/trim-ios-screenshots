    NAME
         trims -- trim iOS screenshots by cropping away the status bar
    
    SYNOPSIS
         trims [-v | -h] | [[-r] path ...]
    
    DESCRIPTION
         For each iOS screenshot given, either as file path or enclosing folder
         path, trims processes the image by cropping away the status bar. It is
         assumed the status bar is located at the top 20 points (40 pixels on a
         Retina display). The trimmed image is written back to the same file.
         
         Screenshots with dimensions different from the known iOS device screen
         sizes are left untouched.
         
         -r       Specifies the recursive flag which causes trims to traverse any
                  encountered folder path recursively, thereby processing all
                  images in all subfolders and their subfolders etc.
         
         -v, --version
                  Prints the program name and version number.
         
         -h, --help
                  Prints the program name and version number and a brief help
                  text.
    AUTHORS
         Joachim Bondo <osteslag@gmail.com>.