package gui_window::project_open;
use strict;
use Jcode;
use Tk;
use Tk::HList;
use base qw(gui_window);
use gui_window::project_edit;
use gui_jchar;

#----------------#
#   Window����   #
#----------------#

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	# Window����
	my $few = $mw->Toplevel;
	$self->{win_obj} = $few;
	#$few->focus;
#	$few->grab;
	$few->title($self->gui_jchar('�ץ������ȡ��ޥ͡�����'));

	# �ꥹ�Ⱥ���
	my $plis = $few->Scrolled(
		'HList',
		-scrollbars=> 'osoe',
		-header => 1,
		-width => 55,
		-command => sub{ $mw->after(10,sub{$self->_open;});},
		-itemtype => 'text',
		-font => 'TKFN',
		-columns => 3,
		-padx => 2,
		-background=> 'white',
		-selectforeground=> 'brown',
		-selectbackground=> 'cyan',
#		-selectmode => 'single',
	)->pack(-fill=>'both',-expand => 'yes');
	$self->{g_list} = $plis;

	$plis->header('create',0,-text => $self->gui_jchar('�оݥե�����'));
	$plis->header('create',1,-text => $self->gui_jchar('�����ʥ���'));
	$plis->header('create',2,-text => $self->gui_jchar('�ǥ��쥯�ȥ�'));

	# �ܥ���
	my $b1 = $few->Button(
		-text => $self->gui_jchar('���'),
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->delete;}); }
	)->pack(-side => 'left',-padx => 2,-pady => 1);
	my $b2 = $few->Button(
		-text => $self->gui_jchar('�Խ�'),
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->edit;}); }
	)->pack(-side => 'left',-pady => 1);
	$few->Button(
		-text => $self->gui_jchar('����'),-padx => 2,
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{
			$self->close;
			gui_window::project_new->open;
		}); }
	)->pack(-side => 'left',-padx => 3,,-pady => 1);
	my $b3 = $few->Button(
		-text => $self->gui_jchar('����'),-padx => 3,
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->_open;}); }
	)->pack(-anchor => 'w',-side => 'right',-padx => 2,,-pady => 1);
	$self->{g_buttons} = [$b1,$b2,$b3];
	
	
	$self->refresh;
	
	# �Ƽ�Х����
	$self->win_obj->bind(
		'<Key-Return>',
		sub {$self->_open}
	);
	$self->win_obj->bind(
		'<Key-Down>',
		sub {
			my @s = $self->list->infoSelection;
			if ($self->{max} > $s[0]){
				$self->list->selectionClear;
				$self->list->selectionSet($s[0] + 1);
			}
		}
	);
	$self->win_obj->bind(
		'<Key-Up>',
		sub {
			my @s = $self->list->infoSelection;
			if ($s[0] > 0){
				$self->list->selectionClear;
				$self->list->selectionSet($s[0] - 1);
			}
		}
	);
	
	MainLoop;
	return $self;
}

#--------------------#
#   �ե��󥯥����   #
#--------------------#

sub edit{
	my $self = shift;
	$self->if_selected or return 0;
	gui_window::project_edit->open($self->projects,$self->selected,$self);
}

sub delete{
	my $self = shift;
	$self->if_selected or return 0;
	$self->projects->delete($self->selected);
	
	$self->refresh;
}

sub _open{
	my $self = shift;
	$self->if_selected or return 0;
	my $project = $self->projects->a_project($self->selected);
	$project->open or return 0;
	$::main_gui->close_all;
	$::main_gui->menu->refresh;
	$::main_gui->inner->refresh;

}

#--------------#
#   �����ǧ   #

sub if_selected{
	my $self = shift;
	my @temp = $self->list->infoSelection;
	if (@temp == 1){
		my $current_file;
		eval{ $current_file = $::project_obj->file_target; };
		if (
			   $self->projects->a_project("$temp[0]")->file_target
			eq $current_file
		){
			gui_errormsg->open(
				type   => 'msg',
				window  => \$self->win_obj,
				msg    => "���Υץ������Ȥϸ��߳�����Ƥ��ޤ���\n���ꤵ�줿����¹ԤǤ��ޤ���"
			);
			return 0;
		}
		$self->{selected} = $temp[0];
		return 1;
	} else {
		gui_errormsg->open(
			type   => 'msg',
			window  => \$self->win_obj,
			msg    => "�ץ������Ȥ����򤷤Ƥ�������"
		);
		return 0;
	}
}

#--------------------------#
#   �ꥹ�ȤΥ�ե�å���   #

sub refresh{
	my $self = shift;
	$self->projects(kh_projects->read);
	$self->list->delete('all');

#	�����ԲĤˤǤ��ʤ�����
#	my $current_file;
#	eval{ $current_file = $::project_obj->file_target; };
	my $n = 0;
	foreach my $i (@{$self->projects->list}){
		$self->list->add($n,-at => $n);
		$self->list->itemCreate($n,0,-text => $self->gui_jchar($i->file_short_name));
		$self->list->itemCreate($n,1,-text => $self->gui_jchar($i->comment));
		$self->list->itemCreate($n,2,-text => $self->gui_jchar($i->file_dir));
#		if ( $current_file eq $i->file_target){
#			$self->list->entryconfigure($n, -state, 'disable');
#		}
		++$n;
	}
	
	$self->{max} = $n - 1;
	if ($n){
		$self->list->selectionSet(0);
	}
	
}

#--------------#
#   ��������   #
#--------------#

sub projects{
	my $self = shift;
	if ($_[0]){
		$self->{projects} = $_[0];
	}
	return $self->{projects};
}

sub list{
	my $self = shift;
	return $self->{g_list};
}

sub buttons{
	my $self = shift;
	return $self->{g_buttons}
}

sub selected{
	my $self = shift;
	return $self->{selected};
}

sub win_name{
	return 'w_open_pro';
}

1;