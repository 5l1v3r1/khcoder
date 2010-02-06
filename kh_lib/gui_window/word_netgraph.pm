package gui_window::word_netgraph;
use base qw(gui_window);

use strict;
use Tk;

use gui_widget::tani;
use gui_widget::hinshi;
use mysql_crossout;
use kh_r_plot;

my $bench = 0;

#-------------#
#   GUI����   #

sub _new{
	my $self = shift;
	my $mw = $::main_gui->mw;
	my $win = $self->{win_obj};
	$win->title($self->gui_jt($self->label));

	my $lf_w = $win->LabFrame(
		-label => 'Words',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both', -expand => 1);

	$self->{words_obj} = gui_widget::words->open(
		parent => $lf_w,
		verb   => '����',
	);

	my $lf = $win->LabFrame(
		-label => 'Options',
		-labelside => 'acrosstop',
		-borderwidth => 2,
	)->pack(-fill => 'both');

	# Edge����
	$lf->Label(
		-text => $self->gui_jchar('���褹�붦���ط���edge��'),
		-font => "TKFN",
	)->pack(-anchor => 'w');

	my $f4 = $lf->Frame()->pack(
		-fill => 'x',
		-pady => 2
	);

	$f4->Label(
		-text => '  ',
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');

	$self->{radio} = 'n';
	$f4->Radiobutton(
		-text             => $self->gui_jchar('�������'),
		-font             => "TKFN",
		-variable         => \$self->{radio},
		-value            => 'n',
		-command          => sub{ $self->refresh;},
	)->pack(-anchor => 'w', -side => 'left');

	$self->{entry_edges_number} = $f4->Entry(
		-font       => "TKFN",
		-width      => 3,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_edges_number}->insert(0,'60');
	$self->{entry_edges_number}->bind("<Key-Return>",sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_edges_number});

	$f4->Radiobutton(
		-text             => $self->gui_jchar('Jaccard������'),
		-font             => "TKFN",
		-variable         => \$self->{radio},
		-value            => 'j',
		-command          => sub{ $self->refresh;},
	)->pack(-anchor => 'w', -side => 'left');

	$self->{entry_edges_jac} = $f4->Entry(
		-font       => "TKFN",
		-width      => 4,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_edges_jac}->insert(0,'0.2');
	$self->{entry_edges_jac}->bind("<Key-Return>",sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_edges_jac});

	$f4->Label(
		-text => $self->gui_jchar('�ʾ�'),
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');

	# Edge��������Node���礭��
	$lf->Checkbutton(
			-text     => $self->gui_jchar('���������ط��ۤ�������������','euc'),
			-variable => \$self->{check_use_weight_as_width},
			-anchor => 'w',
	)->pack(-anchor => 'w');

	my $w_use_freq_as_fsize;

	$lf->Checkbutton(
			-text     => $self->gui_jchar('�и�����¿����ۤ��礭���ߤ�����','euc'),
			-variable => \$self->{check_use_freq_as_size},
			-anchor => 'w',
			-command =>
				sub{
					return unless $w_use_freq_as_fsize;
					if ($self->{check_use_freq_as_size}){
						$w_use_freq_as_fsize->configure(-state, "normal");
					} else {
						$w_use_freq_as_fsize->configure(-state, "disabled");
					}
				},
	)->pack(-anchor => 'w');

	my $fontsize_frame = $lf->Frame()->pack(
		-fill => 'x',
		-pady => 0,
		-padx => 0,
	);

	$fontsize_frame->Label(
		-text => '  ',
		-font => "TKFN",
	)->pack(-anchor => 'w', -side => 'left');
	
	$w_use_freq_as_fsize = $fontsize_frame->Checkbutton(
			-text     => $self->gui_jchar('�ե���Ȥ��礭������','euc'),
			-variable => \$self->{check_use_freq_as_fsize},
			-anchor => 'w',
			-state => 'disabled',
	)->pack(-anchor => 'w');

	# �ե���ȥ�����
	my $ff = $lf->Frame()->pack(
		-fill => 'x',
		-pady => 2,
	);

	$ff->Label(
		-text => $self->gui_jchar('�ե���ȥ�������'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_font_size} = $ff->Entry(
		-font       => "TKFN",
		-width      => 3,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_font_size}->insert(0,'80');
	$self->{entry_font_size}->bind("<Key-Return>",sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_font_size});

	$ff->Label(
		-text => $self->gui_jchar('%'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$ff->Label(
		-text => $self->gui_jchar('  �ץ�åȥ�������'),
		-font => "TKFN",
	)->pack(-side => 'left');

	$self->{entry_plot_size} = $ff->Entry(
		-font       => "TKFN",
		-width      => 4,
		-background => 'white',
	)->pack(-side => 'left', -padx => 2);
	$self->{entry_plot_size}->insert(0,'640');
	$self->{entry_plot_size}->bind("<Key-Return>",sub{$self->calc;});
	$self->config_entry_focusin($self->{entry_plot_size});

	$win->Checkbutton(
			-text     => $self->gui_jchar('�¹Ի��ˤ��β��̤��Ĥ��ʤ�','euc'),
			-variable => \$self->{check_rm_open},
			-anchor => 'w',
	)->pack(-anchor => 'w');

	$win->Button(
		-text => $self->gui_jchar('����󥻥�'),
		-font => "TKFN",
		-width => 8,
		-command => sub{ $mw->after(10,sub{$self->close;});}
	)->pack(-side => 'right',-padx => 2, -pady => 2, -anchor => 'se');

	$win->Button(
		-text => 'OK',
		-width => 8,
		-font => "TKFN",
		-command => sub{ $mw->after(10,sub{$self->calc;});}
	)->pack(-side => 'right', -pady => 2, -anchor => 'se');

	$self->refresh(3);
	return $self;
}

sub refresh{
	my $self = shift;
		
	my ($dis, $nor);
	if ($self->{radio} eq 'n'){
		$nor = $self->{entry_edges_number};
		$dis = $self->{entry_edges_jac};
	} else {
		$nor = $self->{entry_edges_jac};
		$dis = $self->{entry_edges_number};
	}

	$nor->configure(-state => 'normal' , -background => 'white');
	$dis->configure(-state => 'disable', -background => 'gray' );
	
	$nor->focus unless $_[0] == 3;
}

#----------#
#   �¹�   #

sub calc{
	my $self = shift;
	
	# ���ϤΥ����å�
	unless ( eval(@{$self->hinshi}) ){
		gui_errormsg->open(
			type => 'msg',
			msg  => '�ʻ줬1�Ĥ����򤵤�Ƥ��ޤ���',
		);
		return 0;
	}

	my $check_num = mysql_crossout::r_com->new(
		tani     => $self->tani,
		tani2    => $self->tani,
		hinshi   => $self->hinshi,
		max      => $self->max,
		min      => $self->min,
		max_df   => $self->max_df,
		min_df   => $self->min_df,
	)->wnum;
	
	$check_num =~ s/,//g;
	#print "$check_num\n";

	if ($check_num < 5){
		gui_errormsg->open(
			type => 'msg',
			msg  => '���ʤ��Ȥ�5�İʾ����и�����򤷤Ʋ�������',
		);
		return 0;
	}

	if ($check_num > 300){
		my $ans = $self->win_obj->messageBox(
			-message => $self->gui_jchar
				(
					 '���ߤ�����Ǥ�'.$check_num.'�줬ʬ�Ϥ����Ѥ���ޤ���'
					."\n"
					.'ʬ�Ϥ��Ѥ����ο���100��150���٤ˤ������뤳�Ȥ�侩���ޤ���'
					."\n"
					.'³�Ԥ��Ƥ�����Ǥ�����'
				),
			-icon    => 'question',
			-type    => 'OKCancel',
			-title   => 'KH Coder'
		);
		unless ($ans =~ /ok/i){ return 0; }
	}

	$self->{words_obj}->settings_save;

	my $ans = $self->win_obj->messageBox(
		-message => $self->gui_jchar
			(
			   "���ν����ˤϻ��֤������뤳�Ȥ�����ޤ���\n".
			   "³�Ԥ��Ƥ�����Ǥ�����"
			),
		-icon    => 'question',
		-type    => 'OKCancel',
		-title   => 'KH Coder'
	);
	unless ($ans =~ /ok/i){ return 0; }

	# �ǡ����μ��Ф�
	my $r_command = mysql_crossout::r_com->new(
		tani   => $self->tani,
		tani2  => $self->tani,
		hinshi => $self->hinshi,
		max    => $self->max,
		min    => $self->min,
		max_df => $self->max_df,
		min_df => $self->min_df,
		rownames => 0,
	)->run;

	# �ǡ�������
	$r_command .= "d <- t(d)\n";
	$r_command .= "# END: DATA\n";

	my $fontsize = $self->gui_jg( $self->{entry_font_size}->get );
	$fontsize /= 100;

	&make_plot(
		font_size        => $fontsize,
		plot_size        => $self->gui_jg( $self->{entry_plot_size}->get ),
		n_or_j           => $self->gui_jg( $self->{radio} ),
		edges_num        => $self->gui_jg( $self->{entry_edges_number}->get ),
		edges_jac        => $self->gui_jg( $self->{entry_edges_jac}->get ),
		use_freq_as_size => $self->gui_jg( $self->{check_use_freq_as_size} ),
		use_freq_as_fsize=> $self->gui_jg( $self->{check_use_freq_as_fsize} ),
		use_weight_as_width =>
			$self->gui_jg( $self->{check_use_weight_as_width} ),
		r_command        => $r_command,
		plotwin_name     => 'word_netgraph',
	);

	unless ( $self->{check_rm_open} ){
		$self->close;
	}

}

sub make_plot{
	my %args = @_;

	kh_r_plot->clear_env;

	my $r_command = $args{r_command};

	# �ѥ�᡼����������ʬ
	if ( $args{n_or_j} eq 'j'){
		$r_command .= "edges <- 0\n";
		$r_command .= "th <- $args{edges_jac}\n";
	}
	elsif ( $args{n_or_j} eq 'n'){
		$r_command .= "edges <- $args{edges_num}\n";
		$r_command .= "th <- 0\n";
	}
	$r_command .= "cex <- $args{font_size}\n";

	unless ( $args{use_freq_as_size} ){
		$args{use_freq_as_size} = 0;
	}
	$r_command .= "use_freq_as_size <- $args{use_freq_as_size}\n";

	unless ( $args{use_freq_as_fsize} && $args{use_freq_as_size}){
		$args{use_freq_as_fsize} = 0;
	}
	$r_command .= "use_freq_as_fontsize <- $args{use_freq_as_fsize}\n";

	unless ( $args{use_weight_as_width} ){
		$args{use_weight_as_width} = 0;
	}
	$r_command .= "use_weight_as_width <- $args{use_weight_as_width}\n";

	$r_command .= &r_plot_cmd_p1;

	# �ץ�åȺ���
	
	use Benchmark;
	my $t0 = new Benchmark;
	
	my $flg_error = 0;
	my $plot1 = kh_r_plot->new(
		name      => $args{plotwin_name}.'_1',
		command_f =>
			 $r_command
			."\ncom_method <- \"cnt-b\"\n"
			.&r_plot_cmd_p2
			.&r_plot_cmd_p3
			.&r_plot_cmd_p4,
		width     => $args{plot_size},
		height    => $args{plot_size},
	) or $flg_error = 1;

	my $plot2 = kh_r_plot->new(
		name      => $args{plotwin_name}.'_2',
		command_f =>
			 $r_command
			."\ncom_method <- \"cnt-d\"\n"
			.&r_plot_cmd_p2
			.&r_plot_cmd_p3
			.&r_plot_cmd_p4,
		command_a =>
			 "com_method <- \"cnt-d\"\n"
			.&r_plot_cmd_p2
			.&r_plot_cmd_p4,
		width     => $args{plot_size},
		height    => $args{plot_size},
	) or $flg_error = 1;

	my $plot3 = kh_r_plot->new(
		name      => $args{plotwin_name}.'_3',
		command_f =>
			 $r_command
			."\ncom_method <- \"com-b\"\n"
			.&r_plot_cmd_p2
			.&r_plot_cmd_p3
			.&r_plot_cmd_p4,
		command_a =>
			 "com_method <- \"com-b\"\n"
			.&r_plot_cmd_p2
			.&r_plot_cmd_p4,
		width     => $args{plot_size},
		height    => $args{plot_size},
	) or $flg_error = 1;

	my $plot4 = kh_r_plot->new(
		name      => $args{plotwin_name}.'_4',
		command_f =>
			 $r_command
			."\ncom_method <- \"com-g\"\n"
			.&r_plot_cmd_p2
			.&r_plot_cmd_p3
			.&r_plot_cmd_p4,
		command_a =>
			 "com_method <- \"com-g\"\n"
			.&r_plot_cmd_p2
			.&r_plot_cmd_p4,
		width     => $args{plot_size},
		height    => $args{plot_size},
	) or $flg_error = 1;

	my $plot5 = kh_r_plot->new(
		name      => $args{plotwin_name}.'_5',
		command_f =>
			 $r_command
			."\ncom_method <- \"none\"\n"
			.&r_plot_cmd_p2
			.&r_plot_cmd_p3
			.&r_plot_cmd_p4,
		command_a =>
			 "com_method <- \"none\"\n"
			.&r_plot_cmd_p2
			.&r_plot_cmd_p4,
		width     => $args{plot_size},
		height    => $args{plot_size},
	) or $flg_error = 1;

	my $t1 = new Benchmark;
	print timestr(timediff($t1,$t0)),"\n" if $bench;

	# ����μ�����û���С�������
	my $info;
	$::config_obj->R->send('
		print(
			paste(
				"khcoderN ",
				length(get.vertex.attribute(n2,"name")),
				", E ",
				length(get.edgelist(n2,name=T)[,1]),
				", D ",
				substr(paste( round( graph.density(n2), 3 ) ), 2, 5 ),
				sep=""
			)
		)
	');
	$info = $::config_obj->R->read;
	if ($info =~ /"khcoder(.+)"/){
		$info = $1;
	} else {
		$info = undef;
	}

	# ����μ�����Ĺ���С�������
	my $info_long;
	$::config_obj->R->send('
		print(
			paste(
				"khcoderNodes ",
				length(get.vertex.attribute(n2,"name")),
				" (",
				length(get.vertex.attribute(n,"name")),
				"), Edges ",
				length(get.edgelist(n2,name=T)[,1]),
				" (",
				length(get.edgelist(n,name=T)[,1]),
				"), Density ",
				substr(paste( round( graph.density(n2), 3 ) ), 2, 5 ),
				", Min. Jaccard ",
				substr( paste( round( th, 3 ) ), 2, 5),
				sep=""
			)
		)
	');
	$info_long = $::config_obj->R->read;
	if ($info_long =~ /"khcoder(.+)"/){
		$info_long = $1;
	} else {
		$info_long = undef;
	}

	# edge�ο����Ǿ���jaccard�����ʤɤξ����command_f���ղ�
	my ($info_edges, $info_jac);
	if ($info =~ /E ([0-9]+), D/){
		$info_edges = $1;
	}
	$::config_obj->R->send('print( paste( "khcoderJac", th, "ok", sep="" ) )');
	$info_jac = $::config_obj->R->read;
	if ($info_jac =~ /"khcoderJac(.+)ok"/){
		$info_jac = $1;
	}
	foreach my $i ($plot1, $plot2, $plot3, $plot4, $plot5){
		$i->{command_f} .= "\n# edges: $info_edges\n";
		$i->{command_f} .= "\n# min. jaccard: $info_jac\n";
	}

	# �ץ�å�Window�򳫤�
	kh_r_plot->clear_env;
	my $plotwin_id = 'w_'.$args{plotwin_name}.'_plot';
	if ($::main_gui->if_opened($plotwin_id)){
		$::main_gui->get($plotwin_id)->close;
	}
	
	return 0 if $flg_error;
	
	my $plotwin = 'gui_window::r_plot::'.$args{plotwin_name};
	$plotwin->open(
		plots       => [ $plot1, $plot2, $plot3, $plot4, $plot5],
		msg         => $info,
		msg_long    => $info_long,
		no_geometry => 1,
	);
	
	return 1;
}

sub r_plot_cmd_p1{
	return '

# ���ٷ׻�
freq <- NULL
for (i in 1:length( rownames(d) )) {
	freq[i] = sum( d[i,] )
}

# ����ٷ׻� 
d <- dist(d,method="binary")
d <- as.matrix(d)
d <- 1 - d;

# ����պ��� 
library(igraph)
n <- graph.adjacency(d, mode="lower", weighted=T, diag=F)
n <- set.vertex.attribute(
	n,
	"name",
	0:(length(d[1,])-1),
	as.character( 1:length(d[1,]) )
)

# edge��ְ������� 
el <- data.frame(
	edge1            = get.edgelist(n,name=T)[,1],
	edge2            = get.edgelist(n,name=T)[,2],
	weight           = get.edge.attribute(n, "weight"),
	stringsAsFactors = FALSE
)

# ���ͤ�׻� 
if (th == 0){
	if(edges > length(el[,1])){
		edges <- length(el[,1])
	}
	th = quantile(
		el$weight,
		names = F,
		probs = 1 - edges / length(el[,1])
	)
}

# edge��ְ����ƥ���դ�ƺ��� 
el2 <- subset(el, el[,3] >= th)
n2  <- graph.edgelist(
	matrix( as.matrix(el2)[,1:2], ncol=2 ),
	directed	=F
)
n2 <- set.edge.attribute(
	n2, "weight", 0:(length(get.edgelist(n2)[,1])-1), el2[,3]
)
	';
}

sub r_plot_cmd_p2{

return 
'
if (length(get.vertex.attribute(n2,"name")) < 2){
	com_method <- "none"
}

# �濴��
if ( com_method == "cnt-b" || com_method == "cnt-d"){
	if (com_method == "cnt-b"){                   # �޲�
		ccol <- betweenness(
			n2, v=0:(length(get.vertex.attribute(n2,"name"))-1), directed=F
		)
	}
	if (com_method == "cnt-d"){                   # ����
		ccol <-  degree(n2, v=0:(length(get.vertex.attribute(n2,"name"))-1) )
	}
	ccol <- ccol - min(ccol)                      # ��������
	ccol <- ccol * 100 / max(ccol)
	ccol <- trunc(ccol + 1)
	ccol <- cm.colors(101)[ccol]
}

# ���꡼������
if ( com_method == "com-b" || com_method == "com-g"){
	merge_step <- function(n2, m){                # �������Ѥδؿ�
		for ( i in 1:( trunc( length( m ) / 2 ) ) ){
			temp_csize <- community.to.membership(n2, m,i)$csize
			num_max   <- max( temp_csize )
			num_alone <- sum( temp_csize[ temp_csize == 1 ] )
			num_cls   <- length( temp_csize[temp_csize > 1] )
			#print( paste(i, "a", num_alone, "max", num_max, "cls", num_cls) )
			if (
				# ���祳�ߥ�˥ƥ������������Ρ��ɿ���22.5%�ʾ�
				   num_max / length(get.vertex.attribute(n2,"name")) >= 0.225
				# ���ġ����祳�ߥ�˥ƥ���������ñ�ȥΡ��ɿ������礭��
				&& num_max > num_alone
				# ���ġ���������2�ʾ�Υ��ߥ�˥ƥ�����12̤��
				&& num_cls < 12
			){
				return(i)
			}
			# ���祳�ߥ�˥ƥ����������Ρ��ɿ���40%��ۤ���ľ�����Ǥ��ڤ�
			if (num_max / length(get.vertex.attribute(n2,"name")) >= 0.4 ){
				return(i-1)
			}
		}
		return( trunc(length( m ) / 2) )
	}

	if (com_method == "com-b"){                   # �޲�����betweenness��
		com   <- edge.betweenness.community(n2, directed=F)    
		com_m <- community.to.membership(
			n2, com$merges, merge_step(n2,com$merges)
		)
	}

	if (com_method == "com-g"){                   # Modularity
		com   <- fastgreedy.community   (n2, merges=TRUE, modularity=TRUE)    
		com_m <- community.to.membership(
			n2, com$merges, merge_step(n2,com$merges)
		)
	}

	com_col <- NULL # vertex frame                # Vertex�ο���12���ޤǡ�
	ccol    <- NULL # vertex
	col_num <- 1
	library( RColorBrewer )
	for (i in com_m$csize ){
		if ( i == 1){
			ccol    <- c( ccol, "white" )
			com_col <- c( com_col, "gray40" )
		} else {
			if (col_num <= 12){
				ccol    <- c( ccol, brewer.pal(12, "Set3")[col_num] )
				com_col <- c( com_col, "gray40" )
			} else {
				ccol    <- c( ccol, "white" )
				com_col <- c( com_col, "blue" )
			}
			col_num <- col_num + 1
		}
	}
	com_col_v <- com_col[com_m$membership + 1]
	ccol      <- ccol[com_m$membership + 1]

	edg_lty <- NULL                               # edge�ο��ȷ���
	edg_col <- NULL
	for (i in 1:length(el2$edge1)){
		if (
			   com_m$membership[ get.edgelist(n2,name=F)[i,1] + 1 ]
			== com_m$membership[ get.edgelist(n2,name=F)[i,2] + 1 ]
		){
			edg_col <- c( edg_col, "gray55" )
			edg_lty <- c( edg_lty, 1 )
		} else {
			edg_col <- c( edg_col, "gray" )
			edg_lty <- c( edg_lty, 3 )
		}
	}
} else {
	com_col_v <- "gray40"
	edg_col   <- "darkgray"
	edg_lty   <- 1
}

if (com_method == "none"){
	ccol <- "white"
}
';

}


sub r_plot_cmd_p3{

return 
'
# �������
if ( length(get.vertex.attribute(n2,"name")) >= 3 ){
	d4l <- as.dist( shortest.paths(n2) )
	if ( min(d4l) < 1 ){
		d4l <- as.dist( shortest.paths(n2, weights=NA ) )
	}
	if ( max(d4l) == Inf){
		d4l[d4l == Inf] <- vcount(n2)
	}
	lay <-  cmdscale( d4l, k=2 )
	check4fr <- function(d){
		chk <- 0
		for (i in combn( length(d[,1]), 2, simplify=F ) ){
			if (
				   d[i[1],1] == d[i[2],1]
				&& d[i[1],2] == d[i[2],2]
			){
				return( i[1] )
			}
		}
		return( NA )
	}
	while ( is.na(check4fr(lay)) == 0 ){
		mv <-  check4fr(lay)
		lay[mv,1] <- lay[mv,1] + 0.001
		#print( paste( "Moved:", mv ) )
	}
} else {
	lay <- NULL
}

# ����
lay_f <- layout.fruchterman.reingold(n2,
	start   = lay,
	weights = get.edge.attribute(n2, "weight")
)

# ����ͤ�0���Ѵ�����ؿ�
neg_to_zero <- function(nums){
  temp <- NULL
  for (i in 1:length(nums) ){
    if (nums[i] < 0){
      temp[i] <- 0
    } else {
      temp[i] <-  nums[i]
    }
  }
  return(temp)
}

# vertex.size��׻�
if ( use_freq_as_size == 1 ){
	v_size <- freq[ as.numeric( get.vertex.attribute(n2,"name") ) ]
	v_size <- v_size / sd(v_size)
	v_size <- v_size - mean(v_size)
	v_size <- v_size * 3 + 12 # ʬ�� = 3, ʿ�� = 12
	v_size <- neg_to_zero(v_size)
} else {
	v_size <- 15
}

# vertex.label.cex��׻�
if ( use_freq_as_fontsize ==1 ){
	f_size <- freq[ as.numeric( get.vertex.attribute(n2,"name") ) ]
	f_size <- f_size / sd(f_size)
	f_size <- f_size - mean(f_size)
	f_size <- f_size * 0.2 + cex

	for (i in 1:length(f_size) ){
	  if (f_size[i] < 0.6 ){
	    f_size[i] <- 0.6
	  }
	}
} else {
	f_size <- cex
}

# edge.width��׻�
if ( use_weight_as_width == 1 ){
	edg_width <- el2[,3]
	edg_width <- edg_width / sd( edg_width )
	edg_width <- edg_width - mean( edg_width )
	edg_width <- edg_width * 0.6 + 2 # ʬ�� = 0.5, ʿ�� = 2
	edg_width <- neg_to_zero(edg_width)
} else {
	edg_width <- 1
}
'
}

sub r_plot_cmd_p4{

return 
'
# �ץ�å�
par(mai=c(0,0,0,0), mar=c(0,0,0,0), omi=c(0,0,0,0), oma =c(0,0,0,0) )
if ( length(get.vertex.attribute(n2,"name")) > 1 ){
	plot.igraph(
		n2,
		vertex.label       =colnames(d)
		                    [ as.numeric( get.vertex.attribute(n2,"name") ) ],
		vertex.label.cex   =f_size,
		vertex.label.color ="black",
		vertex.label.family= "",
		vertex.color       =ccol,
		vertex.frame.color =com_col_v,
		vertex.size        =v_size,
		edge.color         =edg_col,
		edge.lty           =edg_lty,
		edge.width         =edg_width,
		layout             =lay_f
	)
}
'
}

#--------------#
#   ��������   #

sub label{
	return '��и졦�����ͥåȥ�������ץ����';
}

sub win_name{
	return 'w_word_netgraph';
}

sub min{
	my $self = shift;
	return $self->{words_obj}->min;
}
sub max{
	my $self = shift;
	return $self->{words_obj}->max;
}
sub min_df{
	my $self = shift;
	return $self->{words_obj}->min_df;
}
sub max_df{
	my $self = shift;
	return $self->{words_obj}->max_df;
}
sub tani{
	my $self = shift;
	return $self->{words_obj}->tani;
}
sub hinshi{
	my $self = shift;
	return $self->{words_obj}->hinshi;
}

1;