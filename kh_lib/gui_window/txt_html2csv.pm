package gui_window::txt_html2csv;
use base qw(gui_window);

use strict;

use mysql_html2csv;

#-------------#
#   GUI����   #

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $mw->Toplevel;
	$win->focus;
	$win->title(Jcode->new('�����ǥ��󥰡�ñ�㽸��')->sjis);
	
	$self->{win_obj} = $win;

	my $lf = $win->LabFrame(
		-label => 'Option',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'x');
	
	$lf->Label(
		text => Jcode->new('�ɤ�ñ�̤�1�ԡ�1�������ˤȤ��ƽ��Ϥ��ޤ�����')->sjis,
		font => "TKFN"
	)->pack(anchor => 'w');
	
	my $f1 = $lf->Frame()->pack(fill => 'x',-pady => 3);
	
	$f1->Label(
		text => Jcode->new('������')->sjis,
		font => "TKFN"
	)->pack(anchor => 'w', -side => 'left');
	
	my %pack = (
			-anchor => 'e',
			-pady   => 1,
			-side   => 'left'
	);
	$self->{tani_obj} = gui_widget::tani->open(
		parent => $f1,
		pack   => \%pack
	);
	
	$win->Button(
		-text => Jcode->new('����󥻥�')->sjis,
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->close;});}
	)->pack(-side => 'right',-padx => 2);

	$win->Button(
		-text => 'OK',
		-width => 8,
		-font => "TKFN",
		-command => sub{ $mw->after(10,sub{$self->save;});}
	)->pack(-side => 'right');
	
	
	return $self;
}

#--------------------#
#   �ե��󥯥����   #

sub save{
	my $self = shift;
	
	my @types = (
		[ "csv file",[qw/.csv/] ],
		["All files",'*']
	);
	my $path = $self->win_obj->getSaveFile(
		-defaultextension => '.csv',
		-filetypes        => \@types,
		-title            =>
			Jcode->new('�ƥ����ȥե�������ѷ���̾�����դ�����¸')->sjis,
		-initialdir       => $::config_obj->cwd
	);
	
	if ($path){
		mysql_html2csv->exec(
			tani => $self->tani,
			file => $path,
		);
	}
	
	$self->close;
}


#--------------#
#   ��������   #

sub tani{
	my $self = shift;
	return $self->{tani_obj}->tani;
}

sub win_name{
	return 'w_txt_html2csv';
}

1;