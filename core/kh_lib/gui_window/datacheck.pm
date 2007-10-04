package gui_window::datacheck;
use base qw(gui_window);

use strict;
use Tk;

#------------------#
#   Window�򳫤�   #
#------------------#

sub _new{
	my $self             = shift;
	$self->{dacheck_obj} = shift;

	my $mw = $self->win_obj;

	$mw->title( $self->gui_jchar('ʬ���оݥե�����Υ����å��Ƚ���','euc') );

	my $fr_res = $mw->LabFrame(
		-label       => 'Results & Messages',
		-labelside   => 'acrosstop',
		-borderwidth => 2,
	)->pack(
		-fill   => 'both',
		-expand => 1,
		-anchor => 'n',
		#-side   => 'top'
	);

	my $text_widget = $fr_res->Scrolled(
		"ROText",
		-scrollbars => 'osoe',
		-height     => 12,
		-width      => 80,
	)->pack(
		-padx   => 2,
		-fill   => 'both',
		-expand => 'yes'
	);
	$text_widget->bind("<Key>",[\&gui_jchar::check_key,Ev('K'),\$text_widget]);

	$text_widget->insert(
		'end',
		gui_window->gui_jchar( '����'.$self->{dacheck_obj}->{repo_sum}."\n", 'euc' )
	);

	my $fr_act = $mw->LabFrame(
		-label       => 'Functions',
		-labelside   => 'acrosstop',
		-borderwidth => 2,
	)->pack(
		-fill   => 'x',
		-expand => 0,
		-anchor => 'n',
		#-side   => 'top'
	);

	my $fr_act0 = $fr_act->Frame()->pack(-fill => 'x');
	$fr_act0->Label(
		-text => $self->gui_jchar('���Ĥ��ä��������ξܺ١�'),
	)->pack(-anchor=>'w', -side => 'left');

	$fr_act0->Button(
		-text => $self->gui_jchar('���̤�ɽ��'),
		-font => "TKFN",
		-command => sub{ $mw->after
			(
				10,
				sub {
					$text_widget->insert(
						'end',
						gui_window->gui_jchar(
							'����'.$self->{dacheck_obj}->{repo_full}."\n",
							'euc'
						)
					);
				}
			);
		}
	)->pack(-anchor=>'w', -side => 'left',-padx => 1);

	$fr_act0->Button(
		-text => $self->gui_jchar('�ե��������¸'),
		-font => "TKFN",
		#-width => 8,
		-command => sub{ $mw->after
			(
				10,
				sub {
					$self->save();
				}
			);
		}
	)->pack(-anchor=>'w', -side => 'left', -padx => 1);

	$fr_act0->Label(
		-text => $self->gui_jchar('����ʬ���оݥե�����μ�ư������'),
	)->pack(-anchor=>'w', -side => 'left');

	$fr_act0->Button(
		-text => $self->gui_jchar('�¹�'),
		-font => "TKFN",
		#-width => 8,
		-command => sub{ $mw->after
			(
				10,
				sub {
					$self->edit();
				}
			);
		}
	)->pack(-anchor=>'w', -side => 'left');

	$mw->Button(
		-text => $self->gui_jchar('�Ĥ���'),
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after
			(
				10,
				sub {
					$self->close();
				}
			);
		}
	)->pack(-anchor => 'c',-pady => '0');

	return $self;
}

sub save{
	
}



sub end{
	my $self = shift;
	$self->{dacheck_obj}->clean_up;
}


#--------------#
#   Window̾   #

sub win_name{
	return 'w_datacheck';
}

1;
