package gui_window::outvar_read;
use base qw(gui_window);
use strict;
use Tk;

use gui_errormsg;

use gui_window::outvar_read::tab;
use gui_window::outvar_read::csv;

#---------------------#
#   Window �����ץ�   #
#---------------------#

sub _new{
	my $self = shift;
	
	my $mw = $::main_gui->mw;
	my $wmw= $mw->Toplevel;
	#$wmw->focus;
	$wmw->title($self->win_title);

	my $fra4 = $wmw->LabFrame(
		-label => 'Options',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill=>'x');

	# �ե�����̾����Υե졼��
	my $fra4e = $fra4->Frame()->pack(-expand => 'y', -fill => 'x',-pady => 3);
	
	$fra4e->Label(
		-text => $self->file_label,
		-font => "TKFN",
	)->pack(-side => 'left');
	
	$fra4e->Button(
		-text    => Jcode->new('����')->sjis,
		-font    => "TKFN",
		-command => sub {$mw->after(10,sub { $self->file; });},
	)->pack(-side => 'left');
	
	$self->{entry} = $fra4e->Entry(
		-font  => "TKFN",
		-width => 20,
		-background => 'white'
	)->pack(-side => 'left',-padx => 2);

	# �ɤ߹���ñ�̤λ���
	my $fra4f = $fra4->Frame()->pack(-expand => 'y', -fill => 'x', -pady =>3);
	
	$fra4f->Label(
		text => Jcode->new('�ɤ߹���ñ�̡�')->sjis,
		font => "TKFN"
	)->pack(anchor => 'w', side => 'left');

	my %pack = (
			-anchor => 'w',
			-pady   => 1,
#			-side   => 'right'
	);
	$self->{tani_obj} = gui_widget::tani->open(
		parent => $fra4f,
		pack   => \%pack
	);

	$wmw->Button(
		-text => Jcode->new('����󥻥�')->sjis,
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->close;});}
	)->pack(-side => 'right',-padx => 2);

	$wmw->Button(
		-text => 'OK',
		-width => 8,
		-font => "TKFN",
		-command => sub{ $mw->after(10,sub{$self->_read;});}
	)->pack(-side => 'right');

	MainLoop;
	
	$self->{win_obj} = $wmw;
	return $self;
}

#--------------#
#   �ɤ߹���   #
#--------------#

sub _read{
	my $self = shift;

	# ���ϥ����å�
	unless (-e $self->{entry}->get){
		gui_errormsg->open(
			type   => 'msg',
			msg    => Jcode->new('�ե���������������ꤷ�Ʋ�������')->sjis,
			window => \$self->{win_obj},
		);
		return 0;
	}

	# �ɤ߹��ߤμ¹�
	$self->__read or return 0;

	# �ʲ��ϴ�λ����
	
	# �ѿ��ꥹ��Window�򥪡��ץ�
	$self->close;
	my $list = gui_window::outvar_list->open;
	$list->_fill;
	
	# �֥����ǥ��󥰡������ѿ��ȤΥ������ס�Window�������Ƥ������
	if ( $::main_gui->if_opened('w_cod_outtab') ){
		$::main_gui->get('w_cod_outtab')->fill;
	}
}

1;
