package gui_window::cod_out;
use base qw(gui_window);

use strict;

use gui_window::cod_out::spss;
use gui_window::cod_out::csv;

#-------------#
#   GUI�쐻   #

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $mw->Toplevel;
	$win->focus;
	$win->title(Jcode->new($self->win_label)->sjis);
	$self->{win_obj} = $win;

	my $lf = $win->LabFrame(
		-label => 'Entry',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'x');

	# ���[���E�t�@�C��
	$self->{codf_obj} = gui_widget::codf->open(
		parent => $lf
	);

	# �R�[�f�B���O�P��
	my $f2 = $lf->Frame()->pack(expand => 'y', fill => 'x', -pady => 3);
	$f2->Label(
		text => Jcode->new('�R�[�f�B���O�P�ʁF')->sjis,
		font => "TKFN"
	)->pack(anchor => 'w', side => 'left');
	my %pack = (
			-anchor => 'e',
			-pady   => 1,
			-side   => 'left'
	);
	$self->{tani_obj} = gui_widget::tani->open(
		parent => $f2,
		pack   => \%pack
	);
	
	$win->Button(
		-text => Jcode->new('�L�����Z��')->sjis,
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->close;});}
	)->pack(-side => 'right',-padx => 2);

	$win->Button(
		-text => 'OK',
		-width => 8,
		-font => "TKFN",
		-command => sub{ $mw->after(10,sub{$self->_save;});}
	)->pack(-side => 'right');
	
	return $self;
}

#--------------#
#   �A�N�Z�T   #

sub cfile{
	my $self = shift;
	$self->{codf_obj}->cfile;
}

sub tani{
	my $self = shift;
	return $self->{tani_obj}->tani;
}



1;
