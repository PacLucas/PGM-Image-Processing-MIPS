#~~~~~~~~~~~~~~~~~~~~~~~~~ Cálculo do Modelo de Fundo ~~~~~~~~~~~~~~~~~~~~~~~~~
# -> Cálculo feito através da média de frames em imagens de extensão .PGM 
# (Portable Gray Map) no qual diferencia o fundo do objeto
#
# -> .PGM Format:
# 1. A "magic number" for identifying the file type. A pgm image's 
#  magic number is the two characters "P5".
# 2. Whitespace (blanks, TABs, CRs, LFs).
# 3. A width, formatted as ASCII characters in decimal.
# 4. Whitespace.
# 5. A height, again in ASCII decimal.
# 6. Whitespace.
# 7. The maximum gray value (Maxval), again in ASCII decimal. 
#  Must be less than 65536, and more than zero.
# 8. A single whitespace character (usually a newline).
# 9. A raster of Height rows, in order from top to bottom. 
#  Each row consists of Width gray values, in order from left to right. 
#  Each gray value is a number from 0 through Maxval, with 0 being black and 
#  Maxval being white. Each gray value is represented 
#  in pure binary by either 1 or 2 bytes. If the Maxval is less than 256, 
#  it is 1 byte. Otherwise, it is 2 bytes. The most significant byte is first.
#
# 
#
#
#