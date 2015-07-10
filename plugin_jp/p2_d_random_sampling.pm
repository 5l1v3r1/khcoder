package p2_d_random_sampling;
use strict;

#--------------------------#
#   ���Υץ饰���������   #

sub plugin_config{
	return {
		name     => '�����ࡦ����ץ��',
		menu_cnf => 0,
		menu_grp => '�ǡ�������',
	};
}

#----------------------------------------#
#   ��˥塼������˼¹Ԥ����롼����   #

sub exec{
	gui_window::random_sampling->open; # GUI��ư
}


#-------------------------------#
#   GUI���Τ���Υ롼����   #

package gui_window::random_sampling;
use base qw(gui_window);
use strict;
use Tk;

# Window�κ���
sub _new{
	my $self = shift;
	my $mw = $self->{win_obj};

	$mw->title('Random Sampling');

	$mw->Label(
		-text => $self->gui_jchar('���ϥե����뤫�������˹Ԥ���Ф��ޤ�','euc'),
	)->pack(-anchor => 'w');

	my $fra_lab = $mw->LabFrame(
		-label       => 'Options',
		-labelside   => 'acrosstop',
		-borderwidth => 2
	)->pack(
		-expand => 'yes',
		-fill   => 'both'
	);

	# ����
	my $fra1 = $fra_lab->Frame()->pack(
		-anchor => 'c',
		-fill   => 'x',
		-expand => 'x',
		-pady   => 2,
	);

	$fra1->Label(
		-text => $self->gui_jchar('���ϥե����롧','euc'),
	)->pack(
		-side => 'left',
	);

	$self->{btn1} = $fra1->Button(
		-text => 'Browse',
		-font => 'TKFN',
		-borderwidth => 1,
		-command => sub{ $mw->after
			(10,
				sub { $self->_get_in; }
			);
		}
	)->pack(-padx => '2',-side => 'left');

	$self->{entry_in} = $fra1->Entry()->pack(
		-side   => 'left',
		-fill   => 'x',
		-expand => 'x',
	);

	# ����
	my $fra3 = $fra_lab->Frame()->pack(
		-anchor => 'c',
		-fill   => 'x',
		-expand => 'x',
		-pady   => 2,
	);

	$fra3->Label(
		-text => $self->gui_jchar('���ϥե����롧','euc'),
	)->pack(
		-side => 'left',
	);

	$self->{btn2} = $fra3->Button(
		-text => 'Browse',
		-font => 'TKFN',
		-borderwidth => 1,
		-command => sub{ $mw->after
			(10,
				sub { $self->_get_out; }
			);
		}
	)->pack(-padx => '2',-side => 'left');

	$self->{entry_out} = $fra3->Entry()->pack(
		-side   => 'left',
		-fill   => 'x',
		-expand => 'x',
	);

	$self->{entry_in}->DropSite(
		-dropcommand => [\&Gui_DragDrop::get_filename_droped, $self->{entry_in},],
		-droptypes   => ($^O eq 'MSWin32' ? 'Win32' : ['XDND', 'Sun'])
	);
	$self->{entry_out}->DropSite(
		-dropcommand => [\&Gui_DragDrop::get_filename_droped, $self->{entry_out},],
		-droptypes   => ($^O eq 'MSWin32' ? 'Win32' : ['XDND', 'Sun'])
	);

	# �ѡ������
	my $fra4 = $fra_lab->Frame()->pack(
		-anchor => 'c',
		-fill   => 'x',
		-expand => 'x',
		-pady   => 2,
	);

	$fra4->Label(
		-text => $self->gui_jchar('�Կ���%�˽̾����ޤ����� ','euc'),
	)->pack(
		-side => 'left',
	);

	$self->{entry_per} = $fra4->Entry(
		-width  => '4'
	)->pack(
		-side   => 'left',
	);
	gui_window->config_entry_focusin($self->{entry_per});

	$fra4->Label(
		-text => '%',
	)->pack(
		-side => 'left',
	);
	$self->{entry_per}->insert(0,'10');

	# �ܥ����������
	$mw->Button(
		-text    => 'Cancel',
		-font    => "TKFN",
		-width   => 8,
		-command => sub{ $mw->after(10,sub{$self->close;});}
	)->pack(
		-side => 'right',
		-padx => 2
	);
	$mw->Button(
		-text    => 'OK',
		-width   => 8,
		-font    => "TKFN",
		-command => sub{ $mw->after(10,sub{$self->_exec;});}
	)->pack(
		-side => 'right'
	);

	return $self;
}

sub _get_in{
	my $self = shift;

	my @types = (
		[ "data files",[qw/.txt .xls .xlsx .csv .htm .html/] ],
		["All files",'*']
	);

	#print $::config_obj->cwd, "\n";
	my $path = $self->win_obj->getOpenFile(
		-filetypes  => \@types,
		-title      => $self->gui_jt( 'Input file' ),
		-initialdir => $self->gui_jchar($::config_obj->cwd),
	);

	if ($path){
		$path = $self->gui_jg_filename_win98($path);
		$path = $self->gui_jg($path);
		$path = $::config_obj->os_path($path);
		$self->{entry_in}->delete('0','end');
		$self->{entry_in}->insert(0,$self->gui_jchar($path));
	}
}

sub _get_out{
	my $self = shift;

	my @types = (
		[ "data files",[qw/.txt .xls .xlsx .csv .htm .html/] ],
		["All files",'*']
	);

	#print $::config_obj->cwd, "\n";
	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.csv',
		-filetypes  => \@types,
		-title      => $self->gui_jt( 'Output file' ),
		-initialdir => $self->gui_jchar($::config_obj->cwd),
	);

	if ($path){
		$path = $self->gui_jg_filename_win98($path);
		$path = $self->gui_jg($path);
		$path = $::config_obj->os_path($path);
		$self->{entry_out}->delete('0','end');
		$self->{entry_out}->insert(0,$self->gui_jchar($path));
	}
}

sub _exec{
	my $self = shift;
	
	# �ե�����Υ����å�
	my $file_in = $self->gui_jg_filename_win98( $self->{entry_in}->get() );
	$file_in = $self->gui_jg($file_in);
	$file_in = $::config_obj->os_path($file_in);

	unless (-e $file_in){
		gui_errormsg->open(
			type => 'msg',
			msg  => 'Error: cannot find the input file!',
		);
		return 0;
	}

	my $file_out = $self->gui_jg_filename_win98( $self->{entry_out}->get() );
	$file_out = $self->gui_jg($file_out);
	$file_out = $::config_obj->os_path($file_out);

	if ($file_in eq $file_out){
		gui_errormsg->open(
			type => 'msg',
			msg  => 'Error: you cannot specify the same file as input and output',
		);
		return 0;
	}

	my $th = $self->gui_jg( $self->{entry_per}->get );
	$th = $th / 100;

	# �����μ¹�
	my $w = gui_wait->start;
	open(my $fh_in, '<', $file_in) or
		gui_errormsg->open(
			type => 'file',
			thefile => $file_in,
		);
	;

	open(my $fh_out, '>', $file_out) or
		gui_errormsg->open(
			type => 'file',
			thefile => $file_out,
		);
	;
	
	while (<$fh_in>) {
		if ( rand() <= $th ){
			print $fh_out $_;
		}
	}
	
	close( $file_in );
	close( $file_out );
	
	$self->close;
	$w->end;
}

sub win_name{
	return 'w_random_sampling';
}

1;