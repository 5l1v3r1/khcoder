package gui_window::word_df_freq_plot;
use strict;
use base qw(gui_window);

#------------------#
#   Window�򳫤�   #
#------------------#

sub _new{
	my $self = shift;
	my %args = @_;
	my $mw = $::main_gui->mw;
	my $win = $self->{win_obj};

	$win->title($self->gui_jchar('ʸ�����ʬ�ۡ��ץ�å�','euc'));
	
	#print "image: $args{images}->[1]\n";
	
	$self->{photo} = $win->Label(
		-image => $win->Photo(-file => $args{images}->[1]),
		-borderwidth => 2,
		-relief => 'sunken',
	)->pack(-anchor => 'c');

	my $f1 = $win->Frame()->pack(-expand => 'y', -fill => 'x', -pady => 2);

	$f1->Label(
		-text => $self->gui_jchar(' �п����λ��ѡ�'),
		-font => "TKFN"
	)->pack(-anchor => 'e', -side => 'left');
	
	$self->{optmenu} = gui_widget::optmenu->open(
		parent  => $f1,
		pack    => {-anchor=>'e', -side => 'left', -padx => 0},
		options =>
			[
				[$self->gui_jchar('�и����(X)')  => 1],
				[$self->gui_jchar('�и����(X)���ٿ�(Y)') => 2],
				[$self->gui_jchar('�ʤ�') => 0],
			],
		variable => \$self->{ax},
		command  => sub {$self->renew;},
	);

	$f1->Button(
		-text => $self->gui_jchar('�Ĥ���'),
		-font => "TKFN",
		-width => 8,
		-borderwidth => '1',
		-command => sub{ $mw->after
			(
				10,
				sub {
					$self->close();
				}
			);
		}
	)->pack(-side => 'right');
	
	$self->{images} = $args{images};
	return $self;
}

sub renew{
	my $self = shift;
	
	$self->{photo}->configure(
		image => $self->{win_obj}->Photo(-file => $self->{images}[$self->{ax}])
	);
	$self->{photo}->update;
}

#--------------#
#   Window̾   #

sub win_name{
	return 'w_word_df_freq_plot';
}

1;
