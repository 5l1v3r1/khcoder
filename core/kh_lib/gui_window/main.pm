package gui_window::main;
use base qw(gui_window);
use strict;

use gui_window::main::linux;
use gui_window::main::win32;
use gui_window::main::menu;
use gui_window::main::inner;

use Tk;

#----------------------------------#
#   �ᥤ�󥦥���ɥ������饹����   #
#----------------------------------#

sub _new{
	# ���饹����
	my $class = 'gui_window::main';
	
	my $self;

	my $mw= MainWindow->new;
	$self->{mw} = $mw;
	bless $self, "$class".'::'.$::config_obj->os;

	# Window�ؤν񤭹���
	$mw->title('KHC [MAIN WINDOW]');          # Window�����ȥ�
	$self->make_font;                              # �ե����
	$self->{menu}  = gui_window::main::menu->make(\$self);   # ��˥塼
	$self->{inner} = gui_window::main::inner->make(\$self);  # Window�����
	$self->{win_obj} = $mw;

	if ($::config_obj->os eq 'win32'){
		$::splash->Destroy;
	}

	$::main_gui = $self;
	return $self;
}

sub start{
	my $self = shift;
	$self->menu->refresh;
	$self->inner->refresh;
}

#--------------#
#   ��������   #
#--------------#

sub mw{
	my $self = shift;
	return $self->{mw};
}
sub inner{
	my $self = shift;
	return $self->{inner}
}
sub menu{
	my $self = shift;
	return $self->{menu};
}

sub win_name{
	return 'main_window';
}
#----------------------#
#   ¾��Window�δ���   #
#----------------------#
sub if_opened{
	my $self        = shift;
	my $window_name = shift;
	my $win;
	if ( defined($self->{$window_name}) ){
		$win = $self->{$window_name}->win_obj;
	} else {
		return 0;
	}
	
	if ( Exists($win) ){
		focus $win;
		return 1;
	} else {
		return 0;
	}
}
sub get{
	my $self        = shift;
	my $window_name = shift;
	return $self->{$window_name};
}
sub opened{
	my $self        = shift;
	my $window_name = shift;
	my $window      = shift;
	
	$self->{$window_name} = $window;
	$::main_gui = $self;
}

sub close{
	my $self        = shift;
	$self->close_all;
	$::config_obj->win_gmtry($self->win_name,$self->win_obj->geometry);
	$::config_obj->save;
	$self->win_obj->destroy;
}

sub close_all{
	my $self = shift;
	foreach my $i (keys %{$self}){
		if ( substr($i,0,2) eq 'w_'){
			my $win;
			if ($self->{$i}){
				my $win = $self->{$i}->win_obj;
				if (Exists($win)){
					$self->{$i}->close;
				}
			}
		}
	}
}



1;
