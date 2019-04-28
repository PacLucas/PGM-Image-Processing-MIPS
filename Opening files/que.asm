#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~ References (in comments [<reference>][<page>])
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# [1] http://spimsimulator.sourceforge.net/HP_AppA.pdf
# ~ Assemblers, Linkers, and the SPIM Simulator
# [2] http://stackoverflow.com/questions/22588905/mips-dynamic-memory-allocation-using-sbrk
# [3] https://www.cs.umd.edu/class/sum2003/cmsc311/Notes/Mips/pseudo.html
# [4] https://www.cs.ucsb.edu/~franklin/64/lectures/mipsassemblytutorial.pdf
# [5] http://fxr.watson.org/fxr/source/sys/fcntl.h?im=10#L65
# ~ file open flags (O_RDONLY|O_WRONLY|O_RDWR|O_ACCMODE)
# [6] https://www.cs.umd.edu/class/sum2003/cmsc311/Notes/Mips/dataseg.html
# ~ Data and Text Segment
# [7] https://de.wikipedia.org/wiki/Portable_Anymap
# [8] http://www.cs.umd.edu/class/sum2003/cmsc311/Notes/Mips/jump.html
# ~ Conditional and Unconditional Jumps
# [9] https://www.doc.ic.ac.uk/lab/secondyear/spim/node16.html
# ~ Branch and Jump Instructions
# [10] http://www.programmingforums.org/thread39778.html
# ~ itoa procedure (assembly MIPS)
# [11] http://stackoverflow.com/questions/4580166/length-of-array-in-mips
# ~ length of array in mips
# [12] http://stackoverflow.com/questions/9180983/mips-memory-management
# ~ mips memory management
# [13] http://stackoverflow.com/questions/18812319/multiplication-using-logical-shifts-in-mips-assembly
# ~ Multiplication using Logical shifts in Mips assembly
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# ~~ Portable_Anymap
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~
# [h] Der Dateikopf ist folgendermaßen aufgebaut:
#   (1) Magischer Wert: Beschreibt das Format der Bilddaten       - 2
#   (2) Leerraum                                                  - 1
#   (3) Breite des Bilds (dezimal in ASCII kodiert)               - 1 ~ 5
#   (4) Leerraum                                                  - 1
#   (5) Höhe des Bilds (dezimal in ASCII kodiert)                 - 1 ~ 5
#   (6) Leerraum                                                  - 1
# [Bei Graustufen- (PGM) und Farbbildern (PPM) zusätzlich noch:]
#   (7) Maximalwert für die Helligkeit (dezimal in ASCII kodiert) - 1 ~ 3
#   (8) Leerraum                                                  - 1
#
# => max bytes: 19
# Gültiger Leerraum sind die folgenden Zeichen: Leerzeichen, Tabulator, Wagenrücklauf (carriage return) und Zeilenvorschub (line feed).
# - Leerzeichen:    0x20 (dec: 32) 0010 0000
# - Tabulator:      0x09 (dec:  9) 0000 1001
# - Wagenrücklauf:  0x0D (dec: 13) 0000 1101
# - Zeilenvorschub: 0x0A (dec: 10) 0000 1010 (newline)
#
# Magic Number; Dateityp; Kodierung
# P1	Portable Bitmap	ASCII
# P2	Portable Graymap	ASCII
# P3	Portable Pixmap	ASCII
# P4	Portable Bitmap	Binär
# P5	Portable Graymap	Binär
# P6	Portable Pixmap	Binär
# P7	Portable Anymap	Binär
#
# Portable Graymap: 8 Bit bzw. 16 Bit
# Wenn der Maximalwert kleiner als 256 ist, werden für die binäre Speicherung nur 8 Bits pro Kanal verwendet, ansonsten 16 Bits im Big Endian-Format.
#
# ASCII: Vor und nach jedem Wert muss ein Leerraum stehen.
# BINARY: Keine Leerzeichen alle 8, bzw 16 Bit ein Wert!
#
# ~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~~

# Aufgabe 1: Bilder laden und speichern

#
# load_img
#
# @param  $a0 pointer to filename
# @return $v0 image content <8bit segments>
# @return $v1 header information <[0]width [1]height [2]brightness>

load_img:
  addi  $sp, $sp, -36          # allocate memory in stack to strore 4 bytes
  sw    $ra, 32($sp)           # save return address to stack
  sw    $s0, 28($sp)           # save $s0 to stack
  sw    $s1, 24($sp)           # save $s0 to stack
  sw    $s2, 20($sp)           # save $s1 to stack
  sw    $s3, 16($sp)           # save $s1 to stack
  sw    $s4, 12($sp)           # save $s1 to stack
  sw    $s5, 8($sp)            # save $s1 to stack
  sw    $s6, 4($sp)            # save $s1 to stack
  sw    $s7, 0($sp)            # save $s1 to stack

  move  $s1, $a0               # save pointer to filename

  lw    $a0, len_header        # amount of byte that should be allocated
  jal   alloc
  move  $s0, $v0               # save address for header

  la    $a0, 0($s1)            # reset pointer to filename
  lw    $a1, O_RDONLY          # flag: open file in read
  la    $a2, 0                 # mode: not needed
  jal   file_open              # jump to  and save position to $ra
  move  $a0, $v0               # save / set file descriptor

  la    $a1, 0($s0)            # buffer address
  lw    $a2, len_header        # load binary - header length
  jal   file_read              # read header

  jal   file_close

  # [h](1) - len 2
  lb    $t0, 1($s0)            # load 2'nd char of header - magic number
  bne   $t0, '5', cant_hndl    # check magic number - can only handle P5 for now..

  li    $s5, 6                 # set char counter 2 for [h][1] + 4x Whitespace

  # [h](3) - len 1 ~ 5
  la    $a0, 3($s0)            # set char pointer to 2 [h](1) + 1 [h](2)
  jal   atoi                   # convert ascii int
  la    $t0, 0($a0)            # save char pointer
  add   $s5, $s5, $v1          # update char counter
  move  $s2, $v0               # save width

  # [h](5) - len 1 ~ 5
  la    $a0, 1($t0)            # set char pointer to + 1 [h](4)
  jal   atoi                   # convert ascii int
  la    $t0, 0($a0)            # save char pointer
  add   $s5, $s5, $v1          # update char counter
  move  $s3, $v0               # save height

  # [h](7) - len 1 ~ 3
  la    $a0, 1($t0)            # set char pointer to + 1 [h](6)
  jal   atoi                   # convert ascii int
  add   $s5, $s5, $v1          # update char counter
  move  $s4, $v0               # save brightness

  # calc needed memory - width * height
  mult  $s2, $s3               # width * height = Hi and Lo registers
  mflo  $s6                    # copy Lo to $t0

  # memory for content
  la    $a0, 0($s6)
  jal   alloc
  move  $s0, $v0               # save address for file content

  la    $a0, 0($s1)            # reset pointer to filename
  lw    $a1, O_RDONLY          # flag: open file in read
  la    $a2, 0                 # mode: not needed
  jal   file_open              # jump to  and save position to $ra
  move  $a0, $v0               # save/set file descriptor

  la    $a1, 0($s0)            # buffer address
  la    $a2, 0($s5)            # length of header
  jal   file_read              # skip header
  la    $a2, 0($s6)            # length of content
  jal   file_read              # read content

  jal   file_close

  # end of load_img: set return values and reset stack.
  la    $a0, 12                # amount of byte that should be allocated
  jal   alloc
  move  $v1, $v0               # set return value - header
  sw    $s2, 0($v1)            # save width
  sw    $s3, 4($v1)            # save height
  sw    $s4, 8($v1)            # save brightness

  move  $v0, $s0               # set return value - image

  lw    $s7, 0($sp)            # load $s1 from stack
  lw    $s6, 4($sp)            # load $s1 from stack
  lw    $s5, 8($sp)            # load $s1 from stack
  lw    $s4, 12($sp)            # load $s0 from stack
  lw    $s3, 16($sp)           # load $s0 from stack
  lw    $s2, 20($sp)           # load $s0 from stack
  lw    $s1, 24($sp)           # load $s0 from stack
  lw    $s0, 28($sp)           # load $s0 from stack
  lw    $ra, 32($sp)           # get return address from stack
  addi  $sp, $sp, 36           # clear reserved bytes
  jr    $ra                    # jump to caller


#########################################

#
# store_img
#
# @param  $a0 image content <8bit segments>
# @param  $a1 header information <[0]width [1]height [2]brightness>
# @param  $a2 filename pointer
# @return void
store_img:
  addi  $sp, $sp, -32          # allocate memory in stack to strore 4 bytes
  sw    $ra, 28($sp)           # save return address to stack
  sw    $s0, 24($sp)           # save $s0 to stack
  sw    $s1, 20($sp)           # save $s0 to stack
  sw    $s2, 16($sp)           # save $s1 to stack
  sw    $s3, 12($sp)           # save $s1 to stack
  sw    $s4, 8($sp)            # save $s1 to stack
  sw    $s5, 4($sp)            # save $s1 to stack
  sw    $s6, 0($sp)            # save $s1 to stack

  move  $s0, $a2               # save $a0 - filename
  move  $s1, $a0               # save $a1 - image
  move  $s2, $a1               # save $a2 - header

  add   $s3, $zero, $zero      # "file pointer"

  lw    $a0, len_header        # amount of byte that should be allocated
  jal   alloc
  move  $a1, $v0               # set return value - header

  # set type
  li    $t0, 'P'
  sb    $t0, 0($a1)
  addiu $a1, $a1, 1
  li    $t0, '5'
  sb    $t0, 0($a1)
  addiu $a1, $a1, 1
  li    $t0, 0x20
  sb    $t0, 0($a1)
  addiu $a1, $a1, 1
  addiu $s3, $s3, 3
  # width
  lw    $a0, 0($s2)
  jal   itoa
  add   $s3, $s3, $v0
  li    $t0, 0x20
  sb    $t0, 0($a1)
  addiu $a1, $a1, 1
  addiu $s3, $s3, 1
  # height
  lw    $a0, 4($s2)
  jal   itoa
  add   $s3, $s3, $v0
  li    $t0, 0x20
  sb    $t0, 0($a1)
  addiu $a1, $a1, 1
  addiu $s3, $s3, 1
  # brightness
  lw    $a0, 8($s2)
  jal   itoa
  add   $s3, $s3, $v0
  li    $t0, 0x0A
  sb    $t0, 0($a1)
  addiu $s4, $a1, 1
  addiu $s3, $s3, 1

  move  $a0, $s0               # reset filename
  lw    $t0, O_WRONLY          # need only to write to file
  lw    $t1, O_CREAT           # if file not exist -> create
  or    $a1, $t0, $t1          # combine flags
  lw    $a2, P_0777            # set permission to 0777 if file not exists
  jal   file_open              # jump to  and save position to $ra
  move  $a0, $v0               # save/set file descriptor

  sub   $a1, $s4, $s3          # set string address for create header
  la    $a2, 0($s3)            # header length
  jal   file_write             # write header

  move  $a1, $s1               # buffer address for content
  lw    $t0, 0($s2)            # width
  lw    $t1, 4($s2)            # height
  mult  $t0, $t1               # width * height = content length/size
  mflo  $a2                    # copy Lo to $t0
  jal   file_write             # write content

  jal   file_close

  lw    $s6, 0($sp)            # load $s1 from stack
  lw    $s5, 4($sp)            # load $s1 from stack
  lw    $s4, 8($sp)            # load $s0 from stack
  lw    $s3, 12($sp)           # load $s0 from stack
  lw    $s2, 16($sp)           # load $s0 from stack
  lw    $s1, 20($sp)           # load $s0 from stack
  lw    $s0, 24($sp)           # load $s0 from stack
  lw    $ra, 28($sp)           # get return address from stack
  addi  $sp, $sp, 32           # clear reserved bytes
  jr    $ra                    # jump to caller

#########################################


# Aufgabe 2: Verringern der Bildauflösung

#
# interpolate2
#
# @param  $a0 image content <8bit segments>
# @param  $a1 header information <[0]width [1]height [2]brightness>
# @return void
interpolate2:
  addi  $sp, $sp, -36          # allocate memory in stack to strore 4 bytes
  sw    $ra, 32($sp)           # save return address to stack
  sw    $s0, 28($sp)           # save $s0 to stack
  sw    $s1, 24($sp)           # save $s0 to stack
  sw    $s2, 20($sp)           # save $s1 to stack
  sw    $s3, 16($sp)           # save $s1 to stack
  sw    $s4, 12($sp)           # save $s1 to stack
  sw    $s5, 8($sp)            # save $s1 to stack
  sw    $s6, 4($sp)            # save $s1 to stack
  sw    $s7, 0($sp)            # save $s1 to stack

  lw    $t0, 0($a1)            # get current width
  lw    $t1, 4($a1)            # get current height

  # save new width
  srl   $t2, $t0, 1            # width / 2
  sw    $t2, 0($a1)            # save to header
  # save new height
  srl   $t3, $t1, 1            # height / 2
  sw    $t3, 4($a1)            # save to header

  li    $s2, 0                 # set row counter to zero
  li    $s3, 0                 # set column counter to zero

  la    $s0, 0($a0)            # n     column pointer
  la    $s1, 0($a0)            # n + 1 column pointer
  add   $s1, $s1, $t0          # set colum offset (n + 1)
interpolate2.loop:
  lbu   $t5, 0($s0)            # 1. get pixel
  lbu   $t6, 1($s0)            # 2. get pixel + 1
  add   $t5, $t5, $t6          # 1. = 1. + 2.

  lbu   $t6, 0($s1)            # 3. get pixel beneath (n + 1)
  add   $t5, $t5, $t6          # 1. = 1. + 3.
  lbu   $t6, 1($s1)            # 4. get pixel + 1 (from offset column)
  add   $t5, $t5, $t6          # 1. = 1. + 4.

  srl   $t5, $t5, 2            # get average of pixel values ( 1. = 1. / 2^2 )

  sb    $t5, 0($a0)            # save average back to memory
  add   $a0, $a0, 1            # set pointer to next pixel

  add   $s0, $s0, 2            # set pointer to next pixel to interpolate
  add   $s1, $s1, 2            # set pointer to next pixel to interpolate (offset column)
  add   $s2, $s2, 1            # row counter +1

  # jump column
  bne   $s2, $t2, interpolate2.row_not_finished # check if row if not finished yet
  add   $s2, $zero, $zero      # row is finished set row counter to zero
  add   $s0, $s0, $t0          # jump one column
  add   $s1, $s1, $t0          # jump one column (offset column)
  add   $s3, $s3, 1            # column counter +1

interpolate2.row_not_finished:
  bne   $s3, $t3, interpolate2.loop # check if columns are left

  mult  $t2, $t3               # new width * new height
  mflo  $t0                    # = new content length
  sub   $a0, $a0, $t0          # reset pointer to beginning


  lw    $s7, 0($sp)            # load $s1 from stack
  lw    $s6, 4($sp)            # load $s1 from stack
  lw    $s5, 8($sp)            # load $s1 from stack
  lw    $s4, 12($sp)           # load $s0 from stack
  lw    $s3, 16($sp)           # load $s0 from stack
  lw    $s2, 20($sp)           # load $s0 from stack
  lw    $s1, 24($sp)           # load $s0 from stack
  lw    $s0, 28($sp)           # load $s0 from stack
  lw    $ra, 32($sp)           # get return address from stack
  addi  $sp, $sp, 36           # clear reserved bytes
  jr    $ra                    # jump to caller

#########################################

#
# interpolate
# ~ calls interpolate2
#
# @param  $a0 image content <8bit segments>
# @param  $a1 header information <[0]width [1]height [2]brightness>
# @param  $a2 power (2^n) of reduction
# @return void
interpolate:
  addi  $sp, $sp, -4          # allocate memory in stack to strore 4 bytes
  sw    $ra, 0($sp)           # save return address to stack

interpolate.loop:
  jal   interpolate2           # call interpolate2 reduce by half
  sub   $a2, $a2, 1            # power - 1
  bnez  $a2, interpolate.loop  # repeate unsless power is zero

  lw    $ra, 0($sp)           # get return address from stack
  addi  $sp, $sp, 4           # clear reserved bytes
  jr    $ra                    # jump to caller
#########################################

# Aufgabe 3: Verringern der Farbtiefe

#
# quantize
#
# @param  $a0 image content <8bit segments>
# @param  $a1 header information <[0]width [1]height [2]brightness>
# @param  $a2 quantize factor
# @return void
quantize:
  addi  $sp, $sp, -8          # allocate memory in stack to strore 4 bytes
  sw    $ra, 4($sp)           # save return address to stack
  sw    $s0, 0($sp)           # save $s0 to stack

  li    $s0, 8                 # max color depth to the power of two (2^8)
  sub   $s0, $s0, $a2          # get reduction ratio (8 - n)

  lw    $t0, 8($a1)            # load image brightness
  srl   $t0, $t0, $s0          # reduce by quantize factor ratio

  sw    $t0, 8($a1)            # set max color depth

  lw    $t0, 0($a1)            # get current width
  lw    $t1, 4($a1)            # get current height

  mult  $t0, $t1               # width * height
  mflo  $t2                    # = content length

  la    $t0, 0($a0)            # copy file pointer
quantize.loop:
  lbu   $t1, 0($t0)            # load binary unsigned of char pointer
  srl   $t1, $t1, $s0          # shift color value (eg. n=1 => 8-1=7; lt 128 => 0; ge 128 => 1 ~ two colors)
  sb    $t1, 0($t0)            # save binary to the same position

  add   $t0, $t0, 1            # move char pointer
  sub   $t2, $t2, 1            # content length - 1
  bnez  $t2, quantize.loop     # repeat unless content length is zero

  lw    $s0, 0($sp)            # load $s0 from stack
  lw    $ra, 4($sp)            # get return address from stack
  addi  $sp, $sp, 8            # clear reserved bytes
  jr    $ra                    # jump to caller

#########################################
# custom routines for assignment
#

cant_hndl:
  la    $a0, ascii_chd
  jal   print_string
  #TODO: jump to beginning
  j     exit

#
# reads line/prompts from cli
#
# @params  $a0 address to prompt message
# @params  $a1 buffer address
# @params  $a2 buffer length ~ 0: int; <other>: string
prompt:
  addi  $sp, $sp, -4           # allocate memory in stack to strore 4 bytes
  sw    $ra, 0($sp)            # save return address to stack

  # display message
  jal   print_string

  beqz  $a2, prompt.int
  # get string from console
  move  $a0, $a1               # move buffer address to $a0
  move  $a1, $a2               # move buffer length to $a1
  jal   read_string

  li    $a1, 10                # replace newline
  li    $a2, 0                 # with 0 - end of line
  jal   str_replace

  b     prompt.next
prompt.int:
  # get int from console
  jal   read_int
prompt.next:


  lw    $ra, 0($sp)            # get return address from stack
  addi  $sp, $sp, 4            # clear reserved bytes
  jr    $ra                    # jump to caller

#
# opens file
#
# @param  $a0 file name
# @param  $a1 open flag
# @param  $a2 open mode
# @return $v0 file descriptor
file_open:
  # [1][A-44] open file
  li    $v0, 13                # system call code for open
  syscall                      # open a file (file descriptor returned in $v0)
  bltz  $v0, file_open.err_msg # check if less $zero => error
  jr    $ra                    # jump to caller
file_open.err_msg:
  move  $t0, $a0
  move  $t1, $v0
  li    $a0, 0x0A
  jal   print_char
  jal   print_char
  li    $a0, 'e'
  jal   print_char
  move  $a0, $t1
  jal   print_int
  li    $a0, ' '
  jal   print_char
  li    $a0, 'f'
  jal   print_char
  move  $a0, $a1
  jal   print_int
  li    $a0, ' '
  jal   print_char
  li    $a0, 'm'
  jal   print_char
  move  $a0, $a2
  jal   print_int
  li    $a0, ' '
  jal   print_char
  move  $a0, $t0
  jal   print_string
  la    $a0, ascii_err_file_open
  jal   print_string
  j     exit


#
# reads file
#
# @param  $a0 file descriptor
# @param  $a1 buffer address
# @param  $a1 buffer length
file_read:
  # [1][A-44] read file
  li    $v0, 14                # system call for read from file
  syscall
  jr   $ra                     # jump to caller

#
# writes file - http://stackoverflow.com/questions/25953681/create-and-write-to-file-on-mips
#
# @param  $a0 file descriptor
# @param  $a1 buffer address
# @param  $a2 buffer length
file_write:
  li    $v0, 15                # system call code for open
  bnez  $a2, file_write.skip   # if buffer length is given skip length computation
  la    $a2, file_write._end   # load address of 'end of file'
  subu  $a2, $a2, $a1          # computes the length of the string, this is really a constant
file_write.skip:
  syscall
  jr   $ra                     # jump to caller

#
# closes file
#
# @params  $a0 file descriptor
file_close:
  # [1][A-44] close file
  li   $v0, 16                # system call for close
  syscall                     # close file
  jr   $ra                    # jump to caller


#
# prints ascii to console
#
# @params  $a0 address to string to print
print_string:
  # [1][A-44] print_string
  li    $v0, 4                 # system call code for print_string
  syscall
  jr    $ra                    # jump to caller

#
# print char
#
# @param  $a0 char to print
print_char:
  # [1][A-44] print_char
  li    $v0, 11                # system call code for print_char
  syscall
  jr    $ra                    # jump to caller


#
# print int
#
# @param  $a0 int to print
print_int:
  # [1][A-44] print_int
  li    $v0, 1                 # system call code for print_int
  syscall
  jr    $ra                    # jump to caller



#
# Read string from console
#
# @param  $a0 address where to write
# @param  $a1 length string
read_string:
  # [1][A-44] read_string
  li    $v0, 8                 # system call code for read_string
  syscall
  jr    $ra                    # jump to caller

#
# Read int from console
#
read_int:
  # [1][A-44] read_int
  li    $v0, 5                 # system call code for read_int
  syscall
  jr    $ra                    # jump to caller

#
# dynamic allocating memory
#
# @param  $a0 amount of bytes that should be allocated
# @return $v0 address of allocated memory
alloc:
  # [1][A-22] + [1][A-45] + [2]
  li    $v0, 9                 # system call code for sbrk
  syscall                      # dynamically allocating memory of size 4 bytes at address of file descriptor
  # [4][88] check if zero
  beqz  $v0, out_of_memory     # are we out of memory?
  jr    $ra                    # jump to caller

#
# the routine to call when sbrk fails. jumps to exit.
out_of_memory:
  # [1][A-44] print string
  li    $v0, 4                 # system call code for print_string
  la    $a0, ascii_oom         # load msg
  syscall                      # print msg_oom
  j     exit                   # jump to exit routine

#
# the routine to call to exit the program.
exit:
  # [1][A-44] exit program
  li    $v0, 10                # system call code for exit
  syscall                      # end of program


#
# Replaces $a1 with $a2 within string pointer of $a0
#
# @param  $a0 string pointer
# @param  $a1 char (binary) to find
# @param  $a2 char (binary) to replace
str_replace:
  lb    $t0, 0($a0)            # lb (load byte) transfers one byte of data from main memory to a register.
  beqz  $t0, str_replace.end   # nothing more to check (end of string)
  bne   $t0, $a1, str_replace.next # check current pointer if eq to desired char
  sb    $a2, 0($a0)            # sb (store byte) transfers the lowest byte of data from a register into main memory. /$a2~0
str_replace.next:
  addiu $a0, $a0, 1            # check next char
  b     str_replace            # [9] unconditionally branch to the instruction at the label
str_replace.end:
  jr    $ra                    # jump to caller

#
# Fn returns the number of elements in an array
#
# @param  $a0 array
# @return $v0 int length of array
length:
  addi  $sp, $sp, -8
  sw    $ra, 0($sp)
  sw    $a0, 4($sp)
  li    $t1, 0
length.loop:
  lw    $t2, 0($a0)
  beq   $t2, $0, length.end
  addi  $t1, $t1, 1
  addi  $a0, $a0, 4
  j     length.loop
length.end:
  move  $v0, $t1
  lw    $ra, 0($sp)
  lw    $a0, 4($sp)
  addi  $sp, $sp, 8
  jr    $ra

#
# converts ascii int to int
#
# @params  $a0 string pointer to integer
# @returns $v0 integer
# @returns $v1 char count
atoi:
  li    $v0, 0                 # set $v0 to $zero
  li    $v1, 0                 # set $v1 to $zero
  li    $t1, 10                # multiplyer - dec 10
atoi.loop:
  lb    $t0, 0($a0)            # lb (load byte) transfers one byte of data from main memory to a register.

  blt   $t0, 0x30, atoi.end    # [0x30 = 48 (=0)] nothing more to check (no number)
  bgt   $t0, 0x39, atoi.end    # [0x57 = 57 (=9)] nothing more to check (no number)

  addi  $v1, $v1, 1            # $v1++

  mult  $v0, $t1               # $v0 * base = Hi and Lo registers
  mflo  $v0                    # 32 least significant bits of multiplication to $v0  move  $t2, $a0

  addi  $t0, $t0, -48          # ascii numbers beginn at 48 for '0' ~ 57 for '9'
  add   $v0, $v0, $t0          # add to value

  addiu $a0, $a0, 1            # check next char
  b     atoi.loop              # [9] unconditionally branch to the instruction at the label
atoi.end:
  jr    $ra                    # jump to caller


#
# [] converts integer to ascii
#
# @params  $a0 integer
# @params  $a1 buffer address
# @returns $v0 length of string
itoa:
  addi  $t0, $zero, 10         # devider[base] - dec 10
  add   $t1, $zero, $a0        # $t1 = $a0
  add   $t3, $zero, $zero      # $t3 = 0
itoa.loop:
  div   $t1, $t0               # $t1 / 10
  mflo  $t1                    # $t1 => quotient
  mfhi  $t2                    # $t2 => remainder
  addi  $t2, $t2, 0x30         # Convert to ASCII (+48 ~ [eq 0])
  addi  $sp, $sp, -1           # make space for 1 byte in the stack
  sb    $t2, 0($sp)            # push $t2 in the stack
  addi  $t3, $t3, 1            # $t3++ <count up>
  bne   $t1, $zero, itoa.loop  # if quotient($t1) is not equal zero loop
  add   $v0, $zero, $t3        # save string length
itoa.order:
  lb    $t1, 0($sp)            # pop the last byte for the stack
  addiu $sp, $sp, 1            # reduce the stack size by 1 byte
  # sub   $t2, $v0, $t3          # $t2 = $v0 - $t3
  # sb    $t1, $t2($a1)          # savebyte to the proper location of memory
  sb    $t1, 0($a1)          # savebyte to the proper location of memory
  addiu $a1, $a1, 1
  addi  $t3, $t3, -1           # $t3--
  bne   $t3, $zero, itoa.order # loop itoa.order unless all chars iterated

  # add   $a1, $a1, $v0
  # sb    0x0, $v0($a0) # add null character to the end of the string
  jr    $ra                    # jump to caller


#########################################
# [6] stored data for this program
#
.data

## messages
ascii_oom: .asciiz "\n\nOut of memory! EXIT."
ascii_chd: .asciiz "\n\nCan't handle this Portable Anymap, yet. EXIT."
ascii_err_file_open: .asciiz ": could not open file. EXIT."

ascii_pci: .asciiz "\nChoose image:\n\n1) Enter filename\n2) ./images/wood.pgm\n3) ./images/worn.pgm\n4) ./images/sky.pgm\nn) Exit\n\nChoose: "
ascii_efn: .asciiz "\nEnter filename [max 255 chars]: "

ascii_act: .asciiz "\n[Image in Buffer] Choose action:\n\n1) Write to ./output.pgm\n2) Write to ...\n3) interpolate\n4) quantize\n5) Read new file\nn) Exit\n\nChoose: "
ascii_cft: .asciiz "\nChoose factor [power of two]: "

ascii_ald: .asciiz "\nALL DONE. EXIT."

# test files
file_wood: .asciiz "./images/wood.pgm"
file_worn: .asciiz "./images/worn.pgm"
file_sky:  .asciiz "./images/sky.pgm"

file_output:  .asciiz "./output.pgm"

# 'end of file'
# [see] file_write algorithm
file_write._end:

## buffer
space_fna: .space 0xFF
space_act: .space 0x01

## length - for alloc
len_header:.word 0x13          # [19]  max pgm header length
len_fname: .word 0xFF          # [255] max filename/path

## flags & modes
# [5] file open flags
O_RDONLY:  .word 0x0000        # open for reading only
O_WRONLY:  .word 0x0001        # open for writing only
O_RDWR:    .word 0x0002        # open for reading and writing
O_CREAT:   .word 0x0040        # create if nonexistent
P_0777:    .word 0x01FF

#########################################
# main
#
.text
.globl main

# $s0: pointer address filename/path
main:
  addi  $sp, $sp, -4           # allocate memory in stack to strore 4 bytes
  sw    $ra, 0($sp)            # save return address to stack

  li    $a0, 1         # alloc space for filename/path
  jal   alloc                  # jump to alloc and save position to $ra
  move  $s5, $v0

main.new_file:
  la    $a0, ascii_pci         # pointer to prompt message
  li    $a2, 0                 # buffer leng 0 > int
  jal   prompt
  move  $s5, $v0

  beq   $s5, 1, main.enter_filename # jump to .. if 1
  beq   $s5, 2, main.file_wood # jump to .. if 2
  beq   $s5, 3, main.file_worn # jump to .. if 3
  beq   $s5, 4, main.file_sky  # jump to .. if 4
  j     main.exit              # else exit

main.enter_filename:
  la    $a0, ascii_efn         # pointer to prompt message
  la    $a1, space_fna         # pointer to filename buffer
  lw    $a2, len_fname         # buffer leng
  jal   prompt                 # prompt
  la    $s2, space_fna         # save filename
  j     main.read_file         # goto main.read_file
main.file_wood:
  la    $s2, file_wood         # open images/wood.pgm
  j     main.read_file         # goto main.read_file
main.file_worn:
  la    $s2, file_worn         # open images/worn.pgm
  j     main.read_file         # goto main.read_file
main.file_sky:
  la    $s2, file_sky          # open images/sky.pgm

main.read_file:
  la    $a0, 0($s2)            # address to filename
  jal   load_img               # load image
  move  $s0, $v0               # save return content
  move  $s1, $v1               # save return header infos

main.choose_action:
  la    $a0, ascii_act         # pointer to prompt message
  li    $a2, 0                 # buffer leng 0 > int
  jal   prompt                 # prompt next action
  move  $s5, $v0

  beq   $s5, 1, main.output    # jump to .. if 1
  beq   $s5, 2, main.write_to  # jump to .. if 2
  beq   $s5, 3, main.interpolate # jump to .. if 3
  beq   $s5, 4, main.quantize  # jump to .. if 4
  beq   $s5, 5, main.new_file  # jump to .. if 5
  j     main.exit              # else exit

main.output:
  la    $a0, 0($s0)            # load file content
  la    $a1, 0($s1)            # load header infos
  la    $a2, file_output       # set output file './output.pgm'
  jal   store_img              # write image
  j     main.choose_action     # go back to action menu
main.write_to:
  la    $a0, ascii_efn         # pointer to prompt message
  la    $a1, space_fna         # pointer to filename buffer
  lw    $a2, len_fname         # buffer leng
  jal   prompt                 # prompt filename
  la    $a2, space_fna         # set custom filename
  la    $a0, 0($s0)            # set content
  la    $a1, 0($s1)            # set header infos
  jal   store_img              # write file
  j     main.choose_action     # go back to action menu
main.interpolate:
  la    $a0, ascii_cft         # pointer to prompt message
  li    $a2, 0                 # buffer leng 0 > int
  jal   prompt                 # prompt interpolate arg
  move  $a2, $v0               # set $a2 power (2^n) of reduction
  la    $a0, 0($s0)            # set image content
  la    $a1, 0($s1)            # set header infos
  jal   interpolate            # interpolate
  j     main.choose_action     # go back to action menu
main.quantize:
  la    $a0, ascii_cft         # pointer to prompt message
  li    $a2, 0                 # buffer leng 0 > int
  jal   prompt                 # prompt quantize arg
  move  $a2, $v0               # set $a2 quantize factor
  la    $a0, 0($s0)            # set image content
  la    $a1, 0($s1)            # set image header infos
  jal   quantize               # quantize
  j     main.choose_action     # go back to action menu

main.exit:
  la    $a0, ascii_ald
  jal   print_string           # print goodbye
  lw    $ra, 0($sp)            # get return address from stack
  addi  $sp, $sp, 4            # clear reserved bytes
  jr    $ra