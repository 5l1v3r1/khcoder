package gui_window::force_color;
use base qw(gui_window);
use strict;

#------------------#
#   Window�򳫤�   #
#------------------#

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $mw->Toplevel;
	$win->title(Jcode->new('��Ĵ�������')->sjis);

	my $lf = $win->LabFrame(
		-label => 'List',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both',-expand => 'y');

	$lf->Label(
		-text => Jcode->new('���ʲ��θ��դ���˶�Ĵ����ޤ�')->sjis,
		-font => "TKFN",
	)->pack(
		-anchor =>'w',
		-padx   => 2,
		-pady   => 2,
	);

	my $plis = $lf->Scrolled(
		'HList',
		-scrollbars=> 'osoe',
		-header => 1,
		-width => 30,
		#-command => sub{ $mw->after(10,sub{$self->_open;});},
		-itemtype => 'text',
		-font => 'TKFN',
		-columns => 2,
		-padx => 2,
		-background=> 'white',
		-selectforeground=> 'brown',
		-selectbackground=> 'cyan',
		-selectmode => 'single',
	)->pack(-fill=>'both',-expand => 'yes');
	$plis->header('create',0,-text => Jcode->new('��и� / ʸ����')->sjis);
	$plis->header('create',1,-text => Jcode->new('������')->sjis);

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
		-command => sub{ $mw->after(10,sub{$self->_make_new;});}
	)->pack(-side => 'right');
	
	$self->{list}    = $plis;
	$self->{win_obj} = $win;
	
	$self->refresh;
	return $self;
}

#----------------------#
#   ��Ĵ�ꥹ�Ȥι���   #

sub refresh{
	my $self = shift;
	$self->list->delete('all');
	my $row = 0;
	my $h = mysql_exec->select("SELECT name, type FROM d_force",1)->hundle;
	while (my $i = $h->fetch){
		$self->list->add($row,-at => "$row");
		$self->list->itemCreate($row,0,-text => Jcode->new($i->[0])->sjis);
		$self->list->itemCreate($row,1,-text => Jcode->new($i->[1])->sjis);
		++$row;
	}
}


#--------------#
#   ��������   #
#--------------#

sub list{
	my $self = shift;
	return $self->{list};
}

sub win_name{
	return 'w_force_color'; 
}
1;