package gui_window::main::inner;
use strict;

#----------------------#
#   Window����Ⱥ���   #
#----------------------#

sub make{
	my $class = shift;
	my $gui   = shift;
	my $self;
	my $mw = ${$gui}->mw;

	my $fra1 = $mw->LabFrame(
		-label       => 'Project',
		-labelside   => 'acrosstop',
		-borderwidth => 2,
	)->pack(
		-fill   => 'x',
		-expand => '0',
		-anchor => 'n',
		-side   => 'top'
	);

	my $fra1a = $fra1->Frame(-borderwidth => 2) ->pack(-fill => 'x');
	my $fra1b = $fra1->Frame(-borderwidth => 2) ->pack(-fill => 'x');
	
	my $msg = Jcode->new('���ߤΥץ������ȡ�','euc')->sjis;
	$fra1a->Label(
		-text => "$msg",
		-font => "TKFN"
	)->pack(-anchor=>'w',-side=>'left');
	
	my $cupro = $fra1a->Entry(
		-width      => $::config_obj->mw_entry_length,
		-background => 'gray',
		-font       => 'TKFN',
		-state      => 'disable',
	)->pack(-anchor=>'e',-side=>'right');
	
	$msg = Jcode->new('�����ʥ��ˡ�','euc')->sjis;
	$fra1b->Label(
		-text => "$msg",
		-font => "TKFN"
	)->pack(-anchor=>'w',-side=>'left');

	my $cuprom = $fra1b->Entry(
		-width      => $::config_obj->mw_entry_length,
		-background => 'gray',
		-font       => 'TKFN',
		-state      => 'disable',
	)->pack(-anchor=>'e',-side=>'right');

	my $fra2 = $mw->LabFrame(
		-label       => 'Database Stats',
		-labelside   => 'acrosstop',
		-borderwidth => '2'
	)->pack(
		-fill   => 'both',
		-expand => 'yes',
		-anchor => 'n'
	);

	my $fra2a = $fra2->Frame(-borderwidth => 2)->pack(-fill => 'x',);
	my $fra2b = $fra2->Frame(-borderwidth => 2)->pack(-fill => 'x',);

	$msg = Jcode->new("����ñ�����",'euc')->sjis;
	$fra2a->Label(
		-text => "$msg",
		-font => "TKFN"
	)->pack(-anchor=>'w',-side=>'left');

	my $cuprodbwordsnum = $fra2a->Entry(
		-width      => $::config_obj->mw_entry_length,
		-background => 'gray',
		-font       => 'TKFN',
		-state      => 'disable',
	)->pack(-anchor=>'e',-side=>'right');

	$self->{e_curent_project} = $cupro;
	$self->{e_project_memo}   = $cuprom;
	$self->{e_words_num}      = $cuprodbwordsnum;
	bless $self, $class;
	return $self;
}

#--------------------#
#   ��Ȥν񤭴���   #
#--------------------#
sub refresh{
	my $self = shift;
	my $mw = $::main_gui->mw;
	
	# �ץ�������̾
	my $title;
	if ( length($::project_obj->comment) ){
		$title = $::project_obj->comment;
	} else {
		$title = $::project_obj->file_short_name;
	}
	$title .= ' - KH Coder';
	$mw->title($title);
	$self->entry('e_curent_project', $::project_obj->file_short_name);
	$self->entry('e_project_memo', $::project_obj->comment);
}

#--------------#
#   ��������   #
#--------------#

# ����ȥ꡼�ط�
# $obj->entry('entry_name','content');
# entry names: e_curent_project, e_project_memo, e_words_num

sub entry{
	my $self = shift;
	my $entry_name = shift;
	my $entry_cont = shift;
#	$entry_cont = Jcode->new(\$entry_cont,'euc')->sjis;
	
	my $ent = $self->{$entry_name};
	$ent->configure(-state,'normal');
	$ent->delete(0, 'end');
	$ent->insert('0',"$entry_cont");
	$ent->configure(-state,'disable');
}


1;
