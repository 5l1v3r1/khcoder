package gui_window::cod_count;
use base qw(gui_window);

use gui_hlist;
use gui_widget::tani;
use kh_cod;

use strict;
use Jcode;
use Tk;
use Tk::LabFrame;
use Tk::HList;

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $mw->Toplevel;
	$win->focus;
	$win->title(Jcode->new('�����ǥ��󥰡�ñ�㽸��')->sjis);
	
	$self->{win_obj} = $win;
	
	

#------------------------#
#   ���ץ����������ʬ   #

	my $lf = $win->LabFrame(
		-label => 'Entry',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'x');

	# �롼�롦�ե�����
	my $f1 = $lf->Frame()->pack(expand => 'y', fill => 'x');
	$f1->Label(
		text => Jcode->new('�����ǥ��󥰡��롼�롦�ե����롧')->sjis,
		font => "TKFN",
	)->pack(anchor =>'w',side => 'left');
	$f1->Button(
		-text => Jcode->new('����')->sjis,
		-font => "TKFN",
		-borderwidth => '1',
		-command => sub{ $mw->after(10,sub{$self->_sansyo;});}
	)->pack(-padx => 2, -side => 'left');

	my $e1 = $f1->Label(
		-text => Jcode->new('(����ե�����̵��)')->sjis,
		-font => "TKFN",
	)->pack(-side => 'left');

	if ($::project_obj->last_codf){
		my $path = $::project_obj->last_codf;
		$self->{cfile} = $path;
		substr($path, 0, rindex($path, '/') + 1 ) = '';
		$e1->configure(-text => $path);
	}

	# �����ǥ���ñ��
	my $f2 = $lf->Frame()->pack(expand => 'y', fill => 'x');
	$f2->Label(
		text => Jcode->new('�����ǥ���ñ�̡� ')->sjis,
		font => "TKFN"
	)->pack(anchor => 'w', side => 'left');
	my %pack = (
			-anchor => 'e',
			-padx   => 1,
			-pady   => 1,
			-side   => 'left'
	);
	$self->{tani_obj} = gui_widget::tani->open(
		parent => $f2,
		pack   => \%pack
	);

	$f2->Button(
		-text    => Jcode->new('����')->sjis,
		-font    => "TKFN",
		-width   => 8,
		-command => sub{ $mw->after(10,sub{$self->_calc;});}
	)->pack( -side => 'right',-pady => 2);

#------------------#
#   ���ɽ����ʬ   #

	my $rf = $win->LabFrame(
		-label => 'Result',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both',-expand => 'yes',-anchor => 'n');

	my $hlist_fra = $rf->Frame()->pack(-expand => 'y', -fill => 'both');
	my $lis = $hlist_fra->Scrolled(
		'HList',
		-scrollbars       => 'osoe',
		-header           => 1,
		-itemtype         => 'text',
		-font             => 'TKFN',
		-columns          => 3,
		-padx             => 2,
		-background       => 'white',
		-selectforeground => 'black',
		-selectbackground => 'cyan',
		-selectmode       => 'extended',
		-height           => 10,
	)->pack(-fill =>'both',-expand => 'yes');

	$lis->header('create',0,-text => Jcode->new('������̾')->sjis);
	$lis->header('create',1,-text => Jcode->new('����')->sjis);
	$lis->header('create',2,-text => Jcode->new('�ѡ������')->sjis);

	my $label = $rf->Label(
		text       => 'Ready.',
		font       => "TKFN",
		foreground => 'blue'
	)->pack(side => 'left');

	$rf->Button(
		-text => Jcode->new('���ԡ�')->sjis,
		-font => "TKFN",
		-width => 8,
		-borderwidth => '1',
		-command => sub{ $mw->after(10,sub {gui_hlist->copy($self->list);});} 
	)->pack(-side => 'right', -anchor => 'e', -pady => 1);

	$self->{entry} = $e1;
	$self->{label} = $label;
	$self->{list}  = $lis;
	return $self;
}

#------------------#
#   ���ץ롼����   #

sub _calc{
	my $self = shift;
	
	$self->label->configure(
		-text => 'Counting...',
		-foreground => 'red'
	);
	$self->list->delete('all');
	$self->win_obj->update;
	
	my $tani = $self->tani;
	my $codf = $self->{cfile};
	
	unless (-e $codf){
		my $win = $self->win_obj;
		gui_errormsg->open(
			msg => "�����ǥ��󥰡��롼�롦�ե����뤬¸�ߤ��ޤ���",
			window => \$win,
			type => 'msg',
		);
		$self->label->configure(
			-text => 'Ready.',
			-foreground => 'blue'
		);
		return;
	}
	
	my $result;
	unless ($result = kh_cod->read_file($codf)){
		$self->label->configure(
			-text => 'Ready.',
			-foreground => 'blue'
		);
		return 0;
	}
	$result = $result->count($tani);
	unless ($result){
		$self->label->configure(
			-text => 'Ready.',
			-foreground => 'blue'
		);
		return;
	}


	my $right_style = $self->list->ItemStyle(
		'text',
		-font => "TKFN",
		-anchor => 'e',
		-background => 'white'
	);
	
	my $row = 0;
	foreach my $i (@{$result}){
		$self->list->add($row,-at => "$row");
		$self->list->itemCreate(
			$row,
			0,
			-text  => Jcode->new($i->[0])->sjis,
		);
		$self->list->itemCreate(
			$row,
			1,
			-text => $i->[1],
			-style => $right_style
		);
		$self->list->itemCreate(
			$row,
			2,
			-text => $i->[2],
			-style => $right_style
		);
		++$row;
	}

	$self->label->configure(
		-text => 'Ready.',
		-foreground => 'blue'
	);
	$self->win_obj->update;

}

#------------------#
#   ���ȥ롼����   #
sub _sansyo{
	my $self = shift;
	
	my @types = (
		[ "coding rule files",[qw/.txt .cod/] ],
		["All files",'*']
	);
	
	my $path = $self->win_obj->getOpenFile(
		-filetypes  => \@types,
		-title      => Jcode->new('�����ǥ��󥰡��롼�롦�ե���������򤷤Ƥ�������')->sjis,
		-initialdir => $::config_obj->cwd
	);
	
	if ($path){
		$::project_obj->last_codf($path);
		$self->{cfile} = $path;
		substr($path, 0, rindex($path, '/') + 1 ) = '';
		$self->entry->configure(-text => $path);
	}
}

#--------------#
#   ��������   #

sub tani{
	my $self = shift;
	return $self->{tani_obj}->tani;
}

sub entry{
	my $self = shift;
	return $self->{entry};
}
sub list{
	my $self = shift;
	return $self->{list};
}
sub label{
	my $self = shift;
	return $self->{label};
}
sub win_name{
	return 'w_cod_count';
}


1;
