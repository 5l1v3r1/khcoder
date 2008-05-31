package Gui_DragDrop;
use strict;

#-----------------------#
#   Hlist�ւ̃h���b�v   #
#-----------------------#

sub read_CodeFile_droped{
	my %args = @_;
	my $filename;

	eval {
		if ($^O eq 'MSWin32') {
			$filename = $args{widget}->SelectionGet(
				-selection => $args{selection},
				'STRING'
			);
		} else {
			$filename = $args{widget}->SelectionGet(
				-selection => $args{selection},
				'FILE_NAME'
			);
		}
	};
	
	if ($] > 5.008){
		utf8::decode($filename);
	}
	
	if (-e $filename) {
		$args{selected} = $filename;
		my @args_for_code = %args;
		my @return = Gui_lib::read_selected_coderule(@args_for_code);
		return (@return);
	}
}


#-----------------------#
#   Entry�ւ̃h���b�v   #
#-----------------------#
# �EEntry��Ƀh���b�v���ꂽ�t�@�C���̖��O��}��
#
# �E�Ăяo��
# $EntryWidget->DropSite(
# 	-dropcommand => [\&Gui_DragDrop::get_filename_droped, $EntryWidget,],
# 	-droptypes   => ($^O eq 'MSWin32' ? 'Win32' : ['KDE', 'XDND', 'Sun'])
# );

sub get_filename_droped{
	my($widget, $selection) = @_;
	my $filename;
	# print "sele: $selection\n";
	eval {
		if ($^O eq 'MSWin32') {
			$filename = $widget->SelectionGet(
				-selection => $selection,
				'STRING'
			);
		} else {
			$filename = $widget->SelectionGet(
				-selection => $selection,
				'FILE_NAME'
			);
		}
	};
	
	if ($] > 5.008){
		utf8::decode($filename);
	}
	
	if (-e $filename) {
		$widget->delete('0','end');
		$widget->insert(0,$filename);
	}
}

#----------------------#
#   Text�ւ̃h���b�v   #
#----------------------#
# �EText��Ƀh���b�v���ꂽ�t�@�C�����e��ǂݍ���ő}��
#
# �E�Ăяo��
# $TextWidget->DropSite(
# 	-dropcommand => [\&Gui_DragDrop::read_TextFile_droped,$t],
# 	-droptypes => ($^O eq 'MSWin32' ? 'Win32' : ['KDE', 'XDND', 'Sun'])
# );

sub read_TextFile_droped{
	my($widget, $selection) = @_;
	my $filename;
	eval {
		if ($^O eq 'MSWin32') {
			$filename = $widget->SelectionGet(
				-selection => $selection,
				'STRING'
			);
		} else {
			$filename = $widget->SelectionGet(
				-selection => $selection,
				'FILE_NAME'
			);
		}
	};
	
	if ($] > 5.008){
		utf8::decode($filename);
	}
	
	if (-e $filename) {
		open (DROPED,"$filename") or
			gui_errormsg->open(
				type    => 'file',
				thefile => "$filename"
			);
		while (<DROPED>){
			chomp;
			#unless ($_){
			#	next;
			#}
			#if (substr("$_",'0','1') eq '#'){
			#	next;
			#}
			$widget->insert('end',"$_\n");
		}
		close (DROPED);
	}
}

1;