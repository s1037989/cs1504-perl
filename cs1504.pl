#cs1504.pl
#read barcodes from Symbol CS1504 scanner
#store results to file
#provided compliments of www.obtainium.org 

use strict;

#####
use Device::SerialPort;

sub debug_str{
	my ($string) = @_;
print "\@debug_str\n";

print "\$string : ".$string."\n";
	for (my $cloop = 0; $cloop < length($string); $cloop++) {
		my $thechar = substr($string, $cloop, 1);
		my $printchar = $thechar 
			if (ord($thechar) >= 48); #printable
		print "x[$cloop] : "
			. ord(substr($string, $cloop, 1))
			. " " . sprintf("\%x", ord(substr($string, $cloop, 1)))
			. " " . $printchar . " "
			. "\n";
	}
}

sub crc16 {
	my($msg) = @_;

#this is the complete table
my @word = 
 (0x0000, 0xC0C1, 0xC181, 0x0140, 0xC301, 0x03C0, 0x0280, 0xC241,
  0xC601, 0x06C0, 0x0780, 0xC741, 0x0500, 0xC5C1, 0xC481, 0x0440,
  0xCC01, 0x0CC0, 0x0D80, 0xCD41, 0x0F00, 0xCFC1, 0xCE81, 0x0E40,
  0x0A00, 0xCAC1, 0xCB81, 0x0B40, 0xC901, 0x09C0, 0x0880, 0xC841,
  0xD801, 0x18C0, 0x1980, 0xD941, 0x1B00, 0xDBC1, 0xDA81, 0x1A40,
  0x1E00, 0xDEC1, 0xDF81, 0x1F40, 0xDD01, 0x1DC0, 0x1C80, 0xDC41,
  0x1400, 0xD4C1, 0xD581, 0x1540, 0xD701, 0x17C0, 0x1680, 0xD641,
  0xD201, 0x12C0, 0x1380, 0xD341, 0x1100, 0xD1C1, 0xD081, 0x1040,
  0xF001, 0x30C0, 0x3180, 0xF141, 0x3300, 0xF3C1, 0xF281, 0x3240,
  0x3600, 0xF6C1, 0xF781, 0x3740, 0xF501, 0x35C0, 0x3480, 0xF441,
  0x3C00, 0xFCC1, 0xFD81, 0x3D40, 0xFF01, 0x3FC0, 0x3E80, 0xFE41,
  0xFA01, 0x3AC0, 0x3B80, 0xFB41, 0x3900, 0xF9C1, 0xF881, 0x3840,
  0x2800, 0xE8C1, 0xE981, 0x2940, 0xEB01, 0x2BC0, 0x2A80, 0xEA41,
  0xEE01, 0x2EC0, 0x2F80, 0xEF41, 0x2D00, 0xEDC1, 0xEC81, 0x2C40,
  0xE401, 0x24C0, 0x2580, 0xE541, 0x2700, 0xE7C1, 0xE681, 0x2640,
  0x2200, 0xE2C1, 0xE381, 0x2340, 0xE101, 0x21C0, 0x2080, 0xE041,
  0xA001, 0x60C0, 0x6180, 0xA141, 0x6300, 0xA3C1, 0xA281, 0x6240,
  0x6600, 0xA6C1, 0xA781, 0x6740, 0xA501, 0x65C0, 0x6480, 0xA441,
  0x6C00, 0xACC1, 0xAD81, 0x6D40, 0xAF01, 0x6FC0, 0x6E80, 0xAE41,
  0xAA01, 0x6AC0, 0x6B80, 0xAB41, 0x6900, 0xA9C1, 0xA881, 0x6840,
  0x7800, 0xB8C1, 0xB981, 0x7940, 0xBB01, 0x7BC0, 0x7A80, 0xBA41,
  0xBE01, 0x7EC0, 0x7F80, 0xBF41, 0x7D00, 0xBDC1, 0xBC81, 0x7C40,
  0xB401, 0x74C0, 0x7580, 0xB541, 0x7700, 0xB7C1, 0xB681, 0x7640,
  0x7200, 0xB2C1, 0xB381, 0x7340, 0xB101, 0x71C0, 0x7080, 0xB041,
  0x5000, 0x90C1, 0x9181, 0x5140, 0x9301, 0x53C0, 0x5280, 0x9241,
  0x9601, 0x56C0, 0x5780, 0x9741, 0x5500, 0x95C1, 0x9481, 0x5440,
  0x9C01, 0x5CC0, 0x5D80, 0x9D41, 0x5F00, 0x9FC1, 0x9E81, 0x5E40,
  0x5A00, 0x9AC1, 0x9B81, 0x5B40, 0x9901, 0x59C0, 0x5880, 0x9841,
  0x8801, 0x48C0, 0x4980, 0x8941, 0x4B00, 0x8BC1, 0x8A81, 0x4A40,
  0x4E00, 0x8EC1, 0x8F81, 0x4F40, 0x8D01, 0x4DC0, 0x4C80, 0x8C41,
  0x4400, 0x84C1, 0x8581, 0x4540, 0x8701, 0x47C0, 0x4680, 0x8641,
  0x8201, 0x42C0, 0x4380, 0x8341, 0x4100, 0x81C1, 0x8081, 0x4040);

#; it's possible to generate the table
#python code for this:
## CRC-16 poly: p(x) = x**16 + x**15 + x**2 + 1
## top bit implicit, reflected
#poly = 0xa001
#table = array.array('H')
#for byte in range(256):
#     crc = 0
#     for bit in range(8):
#         if (byte ^ crc) & 1:
#             crc = (crc >> 1) ^ poly
#         else:
#             crc >>= 1
#         byte >>= 1
#     table.append(crc)

		my $chksum = 0xFFFF;

	for (my $cloop = 0; $cloop < length($msg); $cloop++) {
		my $char = substr($msg,$cloop,1);
		$chksum = $word[ord($char) ^ ($chksum & 0xff)] ^ ($chksum >> 8);
	}

   $chksum = ~$chksum % 65536;

		my $crc = chr($chksum >> 8)
			.chr($chksum & 0xff);

return $crc;
}

sub hello {
print "hello\n";
	my ($port) = @_;

	serial_send($port, "\x01\x02\x00");
	my $data = serial_recv($port, 5);
}

sub get_time {
print "get_time\n";
	my ($port) = @_;
	serial_send($port, "\x0a\x02\x00");
	my $time = serial_recv($port);

	#!time should be formatted as perl time
	
return $time;
}

sub get_barcodes {
print "get_barcodes\n";
	my ($port) = @_;
	$port->read_const_time(1000); #1 second

	my %symbologies = (
	  0x16, 'Bookland',
	  0x0E, 'MSI',
	  0x02, 'Codabar',
	  0x11, 'PDF-417',
	  0x0c, 'Code 11',
	  0x26, 'Postbar (Canada)',
	  0x20, 'Code 32',
	  0x1e, 'Postnet (US)',
	  0x03, 'Code 128',
	  0x23, 'Postal (Australia)',
	  0x01, 'Code 39',
	  0x22, 'Postal (Japan)',
	  0x13, 'Code 39 Full ASCII',
	  0x27, 'Postal (UK)',
	  0x07, 'Code 93',
	  0x1c, 'QR code',
	  0x1d, 'Composite',
	  0x31, 'RSS limited',
	  0x17, 'Coupon',
	  0x30, 'RSS-14',
	  0x04, 'D25',
	  0x32, 'RSS Expanded',
	  0x1b, 'Data Matrix',
	  0x24, 'Signature',
	  0x0f, 'EAN-128',
	  0x15, 'Trioptic Code 39',
	  0x0b, 'EAN-13',
	  0x08, 'UPCA',
	  0x4b, 'EAN-13+2',
	  0x48, 'UPCA+2',
	  0x8b, 'EAN-13+5',
	  0x88, 'UPCA+5',
	  0x0a, 'EAN-8',
	  0x09, 'UPCE',
	  0x4a, 'EAN-8+2',
	  0x49, 'UPCE+2',
	  0x8a, 'EAN-8+5',
	  0x89, 'UPCE+5',
	  0x05, 'IATA',
	  0x10, 'UPCE1',
	  0x19, 'ISBT-128',
	  0x50, 'UPCE1+2',
	  0x21, 'ISBT-128 concatenated',
	  0x90, 'UPCE1+5',
	  0x06, 'ITF',
	  0x28, 'Macro PDF'
	);
	
	print "reading barcodes...\n";
	
	serial_send($port, "\x07\x02\x00");
	my $data;
	my $newdata = serial_recv($port);
		while ($newdata) {
		$data .= $newdata;
		#keep trying to get datar>#			sleep(1);
		$newdata = serial_recv($port);
#print "\$newdata : ".$newdata."\n";
print "\$newdata\n";
	}
	
	print "processing...\n";
	my @items;
	
	#data 0-9 is xxx and serial
	my $data = substr($data, 10, -2);
	while ($data) {
		my $length = ord(substr($data,0,1));
		my $first = substr($data, 1, $length);
		$data = substr($data, $length + 1); #remainder
		my $symbology = $symbologies{ord(substr($first,0,1))};
		next if (!$symbology);
#print "\$symbology : ".$symbology."\n";
		my $code = substr($first, 1, -4);
#print "\$code : ".$code."\n";
		#time is a packed binary
		my $t = unpack("B32",substr($first, -4));
		my $sec = oct( "0b".substr($t, 0, 6) );
				my $min = oct( "0b".substr($t, 6, 6) );
		my $hour = oct( "0b".substr($t, 12, 5) );
		my $mday = oct( "0b".substr($t, 17, 5) );
		my $mon = oct( "0b".substr($t, 22, 4) ) - 1;
				my $year = 100 + oct( "0b".substr($t, 26, 6) );
		my $ttime=
			sprintf("%04d",$year + 1900)
			.sprintf("%02d",$mon + 1)
			.sprintf("%02d",$mday)
			.sprintf("%02d",$hour)
			.sprintf("%02d",$min)
			.sprintf("%02d",$sec);
print "\$ttime : $ttime\n";

		my %item = ();
		%item = (
			symbology=>$symbology,
			code=>$code,
			ttime=>$ttime,
			);

		push @items, {%item};

	}

print "items : ".@items."\n";
return @items;
}

sub export_items{
	my (@items) = @_;
	
		#!this should be a datestamped file
	my ($sec,$min,$hour,$mday,$mon,$year,$wday,$yday,$isdst) = localtime(time);
	
	my $datestring =  
				sprintf("%04d",$year + 1900)
		.sprintf("%02d",$mon + 1)
		.sprintf("%02d",$mday)
		.sprintf("%02d",$hour)
		.sprintf("%02d",$min)
		.sprintf("%02d",$sec);
	
		my $outfile = 'cs1504codes.'.$datestring.'.txt';		
		# Name the file
		my $allfile = 'cs1504dump.'.$datestring.'.txt';		
		# Name the file
		print "exporting codes to file $outfile\n";
		print "exporting to file $allfile\n";
		print "items : ".@items."\n";

	open(OUTFILE, '>>'.$outfile);		# Open the file
	open(ALLFILE, '>>'.$allfile);		# Open the file

	for my $i (0..@items-1) {
		print "code : ".$items[$i]{'code'}."\n";
		print OUTFILE $items[$i]{'code'}."\n";
		print ALLFILE $items[$i]{'symbology'}
			."\t".$items[$i]{'code'}
			."\t".$items[$i]{'ttime'}
			."\n";
	}
		
	close(OUTFILE);
	close(ALLFILE);
	
}

sub clear_barcodes {
	my ($port) = @_;

print "clear_barcodes\n";
	serial_send($port, "\x02\x02\x00");
	my $data = serial_recv($port, 5);
}

sub goodbye {
	my ($port) = @_;

print "power_down\n";
	serial_send($port, "\x05\x02\x00");
	my $data = serial_recv($port, 5);
}


sub serial_send {
#print "\@serial_send\n";
	my ($port, $cmd) = @_;

	$port->write($cmd); #interrogate command with crc
		$port->write(crc16($cmd)); #interrogate command with crc
}

sub serial_recv {
#print "\@serial_recv\n";
	my ($port, $length) = @_;
	my $MAX_STRLEN = 255;
		
	my $data = $port->read($length || $MAX_STRLEN);
#	if ($data) {
#	}
	
	return $data;
}

##########
# MAIN

# Set up the serial port
my $port = Device::SerialPort->new("/dev/ttyUSB0");
$port->baudrate(9600);
$port->databits(8);
$port->parity("odd");
$port->stopbits(1);
$port->read_const_time(1000); #1 second
$port->handshake("rts");

hello($port);

get_time($port);

my @items = get_barcodes($port);

export_items(@items);

clear_barcodes($port);

goodbye($port);
