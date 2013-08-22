package plotR::network;

use strict;

use kh_r_plot;

sub new{
	my $class = shift;
	my %args = @_;

	#print "$class\n";

	my $self = \%args;
	bless $self, $class;

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

	unless ( $args{smaller_nodes} ){
		$args{smaller_nodes} = 0;
	}
	$r_command .= "smaller_nodes <- $args{smaller_nodes}\n";

	if ($args{font_bold} == 1){
		$args{font_bold} = 2;
	} else {
		$args{font_bold} = 1;
	}
	$r_command .= "text_font <- $args{font_bold}\n";

	$r_command .= "min_sp_tree <- $args{min_sp_tree}\n";

	$args{use_alpha} = 0 unless ( length($args{use_alpha}) );
	$r_command .= "use_alpha <- $args{use_alpha}\n";

	$args{gray_scale} = 0 unless ( length($args{use_alpha}) );
	$r_command .= "gray_scale <- $args{gray_scale}\n";


	# �ץ�åȺ���
	
	#use Benchmark;
	#my $t0 = new Benchmark;
	
	my @plots = ();
	my $flg_error = 0;
	
	if ($self->{edge_type} eq 'twomode'){
		$plots[0] = kh_r_plot->new(
			name      => $args{plotwin_name}.'_1',
			command_f =>
				 $r_command
				."com_method <- \"twomode_c\"\n"
				.$self->r_plot_cmd_p1
				.$self->r_plot_cmd_p2
				.$self->r_plot_cmd_p3
				.$self->r_plot_cmd_p4,
			width     => $args{plot_size},
			height    => $args{plot_size},
		) or $flg_error = 1;

		$plots[1] = kh_r_plot->new(
			name      => $args{plotwin_name}.'_2',
			command_f =>
				 $r_command
				."com_method <- \"twomode_g\"\n"
				.$self->r_plot_cmd_p1
				.$self->r_plot_cmd_p2
				.$self->r_plot_cmd_p3
				.$self->r_plot_cmd_p4,
			command_a =>
				 "com_method <- \"twomode_g\"\n"
				.$self->r_plot_cmd_p2
				.$self->r_plot_cmd_p4,
			width     => $args{plot_size},
			height    => $args{plot_size},
		) or $flg_error = 1;
	} else {
		$plots[0] = kh_r_plot->new(
			name      => $args{plotwin_name}.'_1',
			command_f =>
				 $r_command
				.$self->r_plot_cmd_p1
				."\ncom_method <- \"cnt-b\"\n"
				.$self->r_plot_cmd_p2
				.$self->r_plot_cmd_p3
				.$self->r_plot_cmd_p4,
			width     => $args{plot_size},
			height    => $args{plot_size},
		) or $flg_error = 1;

		$plots[1] = kh_r_plot->new(
			name      => $args{plotwin_name}.'_2',
			command_f =>
				 $r_command
				."\ncom_method <- \"cnt-d\"\n"
				.$self->r_plot_cmd_p1
				.$self->r_plot_cmd_p2
				.$self->r_plot_cmd_p3
				.$self->r_plot_cmd_p4,
			command_a =>
				 "com_method <- \"cnt-d\"\n"
				.$self->r_plot_cmd_p2
				.$self->r_plot_cmd_p4,
			width     => $args{plot_size},
			height    => $args{plot_size},
		) or $flg_error = 1;

		$plots[2] = kh_r_plot->new(
			name      => $args{plotwin_name}.'_3',
			command_f =>
				 $r_command
				."\ncom_method <- \"cnt-e\"\n"
				.$self->r_plot_cmd_p1
				.$self->r_plot_cmd_p2
				.$self->r_plot_cmd_p3
				.$self->r_plot_cmd_p4,
			command_a =>
				 "com_method <- \"cnt-e\"\n"
				.$self->r_plot_cmd_p2
				.$self->r_plot_cmd_p4,
			width     => $args{plot_size},
			height    => $args{plot_size},
		) or $flg_error = 1;

		$plots[3] = kh_r_plot->new(
			name      => $args{plotwin_name}.'_4',
			command_f =>
				 $r_command
				."\ncom_method <- \"com-b\"\n"
				.$self->r_plot_cmd_p1
				.$self->r_plot_cmd_p2
				.$self->r_plot_cmd_p3
				.$self->r_plot_cmd_p4,
			command_a =>
				 "com_method <- \"com-b\"\n"
				.$self->r_plot_cmd_p2
				.$self->r_plot_cmd_p4,
			width     => $args{plot_size},
			height    => $args{plot_size},
		) or $flg_error = 1;

		$plots[4] = kh_r_plot->new(
			name      => $args{plotwin_name}.'_5',
			command_f =>
				 $r_command
				."\ncom_method <- \"com-r\"\n"
				.$self->r_plot_cmd_p1
				.$self->r_plot_cmd_p2
				.$self->r_plot_cmd_p3
				.$self->r_plot_cmd_p4,
			command_a =>
				 "com_method <- \"com-r\"\n"
				.$self->r_plot_cmd_p2
				.$self->r_plot_cmd_p4,
			width     => $args{plot_size},
			height    => $args{plot_size},
		) or $flg_error = 1;

		$plots[5] = kh_r_plot->new(
			name      => $args{plotwin_name}.'_6',
			command_f =>
				 $r_command
				."\ncom_method <- \"com-g\"\n"
				.$self->r_plot_cmd_p1
				.$self->r_plot_cmd_p2
				.$self->r_plot_cmd_p3
				.$self->r_plot_cmd_p4,
			command_a =>
				 "com_method <- \"com-g\"\n"
				.$self->r_plot_cmd_p2
				.$self->r_plot_cmd_p4,
			width     => $args{plot_size},
			height    => $args{plot_size},
		) or $flg_error = 1;

		$plots[6] = kh_r_plot->new(
			name      => $args{plotwin_name}.'_7',
			command_f =>
				 $r_command
				."\ncom_method <- \"none\"\n"
				.$self->r_plot_cmd_p1
				.$self->r_plot_cmd_p2
				.$self->r_plot_cmd_p3
				.$self->r_plot_cmd_p4,
			command_a =>
				 "com_method <- \"none\"\n"
				.$self->r_plot_cmd_p2
				.$self->r_plot_cmd_p4,
			width     => $args{plot_size},
			height    => $args{plot_size},
		) or $flg_error = 1;
	}
	
	#my $t1 = new Benchmark;
	#print timestr(timediff($t1,$t0)),"\n" if $bench;

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
	foreach my $i (@plots){
		$i->{command_f} .= "\n# edges: $info_edges\n";
		$i->{command_f} .= "\n# min. jaccard: $info_jac\n";
	}

	kh_r_plot->clear_env;
	undef $self;
	undef %args;
	$self->{result_plots} = \@plots;
	$self->{result_info} = $info;
	$self->{result_info_long} = $info_long;
	
	return 0 if $flg_error;
	return $self;
}

sub r_plot_cmd_p1{
	return '

# ���ٷ׻�
if (use_freq_as_size == 1){
	freq <- NULL
	for (i in 1:length( rownames(d) )) {
		freq[i] = sum( d[i,] )
	}
}

# ����ٷ׻� 
d <- dist(d,method="binary")
d <- as.matrix(d)
d <- 1 - d;

# ���פ�edge��������ɸ�ಽ
if ( exists("com_method") ){
	if (com_method == "twomode_c" || com_method == "twomode_g"){
		d[1:n_words,] <- 0

		std <- d[(n_words+1):nrow(d),1:n_words]
		std <- t(std)
		std <- scale(std, center=T, scale=F)
		std <- t(std)

		if ( min(std) < 0 ){
			std <- std - min(std);
		}
		std <- std / max(std)
		
		d[(n_words+1):nrow(d),1:n_words] <- std
	}
}

# ����պ��� 
library(igraph)
new_igraph <- 0
if (as.numeric( substr(sessionInfo()$otherPkgs$igraph$Version, 3,3) ) > 5){
	new_igraph <- 1
}

n <- graph.adjacency(d, mode="lower", weighted=T, diag=F)
n <- set.vertex.attribute(
	n,
	"name",
	(0+new_igraph):(length(d[1,])-1+new_igraph),
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
	n2,
	"weight",
	(0+new_igraph):(length(get.edgelist(n2)[,1])-1+new_igraph),
	el2[,3]
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
if ( com_method == "cnt-b" || com_method == "cnt-d" || com_method == "cnt-e"){
	ccol <- NULL
	if (com_method == "cnt-b"){                   # �޲�
		ccol <- betweenness(
			n2,
			v=(0+new_igraph):(length(get.vertex.attribute(n2,"name"))-1+new_igraph),
			directed=F
		)
	}
	if (com_method == "cnt-d"){                   # ����
		ccol <-  degree(
			n2,
			v=(0+new_igraph):(length(get.vertex.attribute(n2,"name"))-1+new_igraph)
		)
	}
	if (com_method == "cnt-e"){                   # ��ͭ�٥��ȥ�
		try(
			ccol <- evcent(n2)$vector,
			silent = T
		)
	}
	
	# ��������
	if ( gray_scale == 1 ) {
		ccol <- ccol - min(ccol)
		ccol <- 1 - ccol / max(ccol) / 2.5
		ccol <- gray(ccol)
	} else {
		ccol <- ccol - min(ccol)
		ccol <- ccol * 100 / max(ccol)
		ccol <- trunc(ccol + 1)
		ccol <- cm.colors(101)[ccol]
	}

	com_col_v <- "gray40"
	edg_col   <- "gray65"
	edg_lty   <- 1
}

# ���꡼������
if (com_method == "com-b" || com_method == "com-g" || com_method == "com-r"){
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
		com_m$membership <- com_m$membership + new_igraph
	}

	if (com_method == "com-g"){                   # Modularity
		com   <- fastgreedy.community   (n2, merges=TRUE, modularity=TRUE)
		com_m <- community.to.membership(
			n2, com$merges, merge_step(n2,com$merges)
		)
		com_m$membership <- com_m$membership + new_igraph
	}

	if (com_method == "com-r"){                   # Random walks
		com   <-  walktrap.community(
			n2,
			weights=get.edge.attribute(n2, "weight")
		)
		com_m <- NULL
		com_m$membership <- com$membership
		com_m$csize      <- table(com$membership)
	}

	com_col <- NULL # vertex frame                # Vertex�ο���12���ޤǡ�
	ccol    <- NULL # vertex
	col_num <- 1
	library( RColorBrewer )
	for (i in com_m$csize ){
		cu_col <- "white"
		if ( i == 1){
			com_col <- c( com_col, "gray40" )
		} else {
			if (col_num <= 12){
				cu_col  <- brewer.pal(12, "Set3")[col_num]
				com_col <- c( com_col, "gray40" )
			} else {
				com_col <- c( com_col, "blue" )
			}
			col_num <- col_num + 1
		}
		ccol <- c( ccol, cu_col )
	}
	com_col_v <- com_col[com_m$membership + 1 - new_igraph]
	ccol      <- ccol[com_m$membership + 1 - new_igraph]

	edg_lty <- NULL                               # edge�ο��ȷ���
	edg_col <- NULL
	for (i in 1:length(el2$edge1)){
		if (
			   com_m$membership[ get.edgelist(n2,name=F)[i,1] + 1 - new_igraph]
			== com_m$membership[ get.edgelist(n2,name=F)[i,2] + 1 - new_igraph]
		){
			edg_col <- c( edg_col, "gray55" )
			edg_lty <- c( edg_lty, 1 )
		} else {
			edg_col <- c( edg_col, "gray" )
			edg_lty <- c( edg_lty, 3 )
		}
	}
}

# �ѿ������Ф������Ѥ�����Υ��顼
if (com_method == "twomode_c" || com_method == "twomode_g"){
	if ( exists("var_select") ){
		var_select_bak <- var_select
	}
	
	var_select <- substring(
		colnames(d)[ as.numeric( get.vertex.attribute(n2,"name") ) ],
		1,
		2
	) == "<>"

	if (length(var_select[var_select==TRUE]) == 0 && exists("var_select_bak")){
		var_select <- var_select_bak;
	}
}

if (com_method == "twomode_c"){
	ccol <-  degree(
		n2,
		v=(0+new_igraph):(length(get.vertex.attribute(n2,"name"))-1+new_igraph)
	)
	ccol[5 < ccol] <- 5
	ccol <- ccol + 3
	
	library( RColorBrewer )
	ccol <- brewer.pal(8, "Spectral")[ccol]

	ccol[var_select] <- "#FB8072" # #FB8072 #DEEBF7 #FF9966 #FFDAB9 "#F46D43"

	com_col_v <- "gray65"
	edg_col   <- "gray70"
	edg_lty   <- 1

}

if ( exists("saving_emf") || exists("saving_eps") ){
	use_alpha <- 0 
}

if (use_alpha == 1 && com_method != "none" && com_method != "twomode_g"){
	rgb <- col2rgb(ccol) / 256
	ccol <- rgb(
		red  =rgb[1,],
		green=rgb[2,],
		blue =rgb[3,],
		alpha=0.685
	)
}

# ���顼��󥰡֤ʤ��פξ������ο���2010 12/4��
if (com_method == "none" || com_method == "twomode_g"){
	ccol <- "white"
	com_col_v <- "black"
	edg_lty <- 1
	edg_col   <- "gray40"
}

if (com_method == "twomode_g"){
	edg_lty <- 3
}

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

# edge.width��׻�
if ( use_weight_as_width == 1 ){
	edg_width <- el2[,3]
	if ( sd( edg_width ) == 0 ){
		edg_width <- 1
	} else {
		edg_width <- edg_width / sd( edg_width )
		edg_width <- edg_width - mean( edg_width )
		edg_width <- edg_width * 0.6 + 2 # ʬ�� = 0.5, ʿ�� = 2
		edg_width <- neg_to_zero(edg_width)
	}
} else {
	edg_width <- 1
}

# Minimum Spanning Tree
if ( min_sp_tree == 1 ){
	# MST�θ���
	mst <- minimum.spanning.tree(
		n2,
		weights = 1 - get.edge.attribute(n2, "weight"),
		algorithm="prim"
	)

	# MST�˹��פ���edge��Ĵ
	if (length(edg_col) == 1){
		edg_col <- rep(edg_col, length( get.edge.attribute(n2, "weight") ))
	}
	if (length(edg_width) == 1){
	    edg_width <- rep(edg_width, ecount(n2) )
	}

	n2_edges  <- get.edgelist(n2,name=T);
	mst_edges <- get.edgelist(mst,name=T);

	for ( i in 1:ecount(n2) ){
		name_n2 <- paste(
			n2_edges[i,1],
			n2_edges[i,2]
		)
		for ( j in 1:ecount(mst) ){
			name_mst <- paste(
				mst_edges[j,1],
				mst_edges[j,2]
			)
			if ( name_n2 == name_mst ){
				edg_col[i]   <- "gray30"                   # edge�ο�
				edg_width[i] <- 2                          # ����
				if ( length(edg_lty) > 1 ){
					edg_lty[i] <- 1                        # ����
				}
				break
			}
		}
	}
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
if (
	   (com_method == "twomode_c" || com_method == "twomode_g")
	&& ( is.connected(n2) )
){
	lay_f <- layout.kamada.kawai(
		n2,
		start   = lay,
		weights = get.edge.attribute(n2, "weight")
	)
} else {
	lay_f <- layout.fruchterman.reingold(
		n2,
		start   = lay,
		weights = get.edge.attribute(n2, "weight")
	)
}

lay_f <- scale(lay_f,center=T, scale=F)
for (i in 1:2){
	lay_f[,i] <- lay_f[,i] - min(lay_f[,i]); # �Ǿ���0��
	lay_f[,i] <- lay_f[,i] / max(lay_f[,i]); # �����1��
	lay_f[,i] <- ( lay_f[,i] - 0.5 ) * 1.96;
}

# vertex.size��׻�
if ( use_freq_as_size == 1 ){
	v_size <- freq[ as.numeric( get.vertex.attribute(n2,"name") ) ]
	if (com_method == "twomode_c" || com_method == "twomode_g"){
		v_size <- v_size[var_select==FALSE]
	}
	if ( sd(v_size) == 0 ){
		v_size <- 15
	} else {
		v_size <- v_size / sd(v_size)
		v_size <- v_size - mean(v_size)
		v_size <- v_size * 3 + 12 # ʬ�� = 3, ʿ�� = 12
		v_size <- neg_to_zero(v_size)
	}
	if (com_method == "twomode_c" || com_method == "twomode_g"){
		v_size[var_select==FALSE] <- v_size
		v_size[var_select] <- 15
	}
} else {
	v_size <- 15
}

# vertex.label.cex��׻�
if ( use_freq_as_fontsize ==1 ){
	f_size <- freq[ as.numeric( get.vertex.attribute(n2,"name") ) ]
	if (com_method == "twomode_c" || com_method == "twomode_g"){
		f_size <- f_size[var_select==FALSE]
	}
	if ( sd(f_size) == 0 ){
		f_size <- cex
	} else {
		f_size <- f_size / sd(f_size)
		f_size <- f_size - mean(f_size)
		f_size <- f_size * 0.2 + cex
	}

	for (i in 1:length(f_size) ){
	  if (f_size[i] < 0.6 ){
	    f_size[i] <- 0.6
	  }
	}
	if (com_method == "twomode_c" || com_method == "twomode_g"){
		f_size[var_select==FALSE] <- f_size
		f_size[var_select] <- cex
	}
} else {
	f_size <- cex
}

# ������αߤ�����
if (smaller_nodes ==1){
	f_size <- cex
	v_size <- 5
	vertex_label_dist <- 0.75
} else {
	vertex_label_dist <- 0
}

# �����ѿ������Ф���Ȥ����η����䥵����
v_shape <- "circle"
if (com_method == "twomode_c" || com_method == "twomode_g"){
	# �Ρ��ɤη�
	v_shape <- rep("circle", length( get.vertex.attribute(n2,"name") ) )
	v_shape[var_select] <- "square"

	# �����ʱߤ����褷�Ƥ�����ΥΡ��ɥ�����
	if (smaller_nodes == 1){
		# ��٥�ε�Υ
		if (length( vertex_label_dist ) == 1){
			vertex_label_dist <- rep(
				vertex_label_dist,
				length( get.vertex.attribute(n2,"name") )
			)
		}
		vertex_label_dist[var_select] <- 0
		# ������
		if (length( v_size ) == 1){
			v_size <- rep(v_size, length( get.vertex.attribute(n2,"name") ) )
		}
		v_size[var_select] <- 10
	}

	# �����ѤΡ�<>�פ򳰤�
	colnames(d)[
		substring(colnames(d), 1, 2) == "<>"
	] <- substring(
		colnames(d)[
			substring(colnames(d), 1, 2) == "<>"
		],
		3,
		nchar(colnames(d)[
			substring(colnames(d), 1, 2) == "<>"
		],type="c")
	)
}

'
}

sub r_plot_cmd_p4{

return 
'
# ��ζ�Ĵ
if ( exists("v_shape") == FALSE ){
	v_shape    <- "circle"
}
target_ids <-  NULL
if ( exists("target_words") ){
	# ID�μ���
	for (i in 1:length( get.vertex.attribute(n2,"name") ) ){
		for (w in target_words){
			if (
				colnames(d)[ as.numeric(get.vertex.attribute(n2,"name")[i]) ]
				== w
			){
				target_ids <- c(target_ids, i)
			}
		}
	}
	# ����
	if (length(v_shape) == 1){
		v_shape <- rep(v_shape, length( get.vertex.attribute(n2,"name") ) )
	}
	v_shape[target_ids] <- "square"
	# �����ο�
	if (length(com_col_v) == 1){
		com_col_v <- rep(com_col_v, length( get.vertex.attribute(n2,"name") ) )
	}
	com_col_v[target_ids] <- "black"
	# ������
	if (length( v_size ) == 1){
		v_size <- rep(v_size, length( get.vertex.attribute(n2,"name") ) )
	}
	v_size[target_ids] <- 15
	# �����ʱߤ����褷�Ƥ�����
	rect_size <- 0.095
	if (smaller_nodes == 1){
		# ��٥�ε�Υ
		if (length( vertex_label_dist ) == 1){
			vertex_label_dist <- rep(
				vertex_label_dist,
				length( get.vertex.attribute(n2,"name") )
			)
		}
		vertex_label_dist[target_ids] <- 0
		# ������
		if (length( v_size ) == 1){
			v_size <- rep(v_size, length( get.vertex.attribute(n2,"name") ) )
		}
		v_size[target_ids] <- 10
		rect_size <- 0.07
	}
}

# �ץ�å�
if (smaller_nodes ==1){
	par(mai=c(0,0,0,0), mar=c(0,0,1,1), omi=c(0,0,0,0), oma =c(0,0,0,0) )
} else {
	par(mai=c(0,0,0,0), mar=c(0,0,0,0), omi=c(0,0,0,0), oma =c(0,0,0,0) )
}
if ( length(get.vertex.attribute(n2,"name")) > 1 ){
	# �ͥåȥ��������
	plot.igraph(
		n2,
		vertex.label        = "",
		#vertex.label       =colnames(d)
		#                    [ as.numeric( get.vertex.attribute(n2,"name") ) ],
		#vertex.label.cex   =f_size,
		#vertex.label.color ="black",
		#vertex.label.family= "", # Linux��Mac�Ķ��Ǥ�ɬ��
		#vertex.label.dist  =vertex_label_dist,
		vertex.color       =ccol,
		vertex.frame.color =com_col_v,
		vertex.size        =v_size,
		vertex.shape       =v_shape,
		edge.color         =edg_col,
		edge.lty           =edg_lty,
		edge.width         =edg_width,
		layout             =lay_f,
		rescale            =F
	)

	# ��Υ�٥���ɲ�
	lay_f_adj <- NULL
	if (smaller_nodes ==1){
		# [2011 10/19]
		# �������Ρ��ɤ�ɽ������ݤ�plot.igraph�ؿ���vertex.label.dist�����
		# ����ȡ�Ĺ����ʸ������¿���˸줬Υ�줹�������Ǥʤ��ä��Τǡ���ư
		# �ǥ�٥���ɲ�. R 2.12.2 / igraph 0.5.5-2 
		if ( is.null(lay_f_adj) == 1){
			lay_f_adj <- cbind(lay_f_adj, lay_f[,1])
			lay_f_adj <- cbind(lay_f_adj, lay_f[,2] + ( max(lay_f[,2]) - min(lay_f[,2]) ) / 38 )
		}

		labels <- colnames(d)[ as.numeric( get.vertex.attribute(n2,"name") ) ]
		if ( exists("target_words") ){
			text(
				lay_f[target_ids,1],
				lay_f[target_ids,2],
				labels = labels[target_ids],
				font = text_font,
				cex = f_size,
				col = "black"
			)
			labels[target_ids] <- ""
		}

		if ( exists("var_select") ){
			text(
				lay_f[var_select,1],
				lay_f[var_select,2],
				labels = labels[var_select],
				font = text_font,
				cex = f_size,
				col = "black"
			)
			labels[var_select] <- ""
		}

		text(
			lay_f_adj,
			labels = labels,
			pos = 4,
			offset = 0.25,
			font = text_font,
			cex = f_size,
			col = "black"
		)
	} else {
		text(
			lay_f,
			labels = colnames(d)
			         [ as.numeric( get.vertex.attribute(n2,"name") ) ],
			#pos = 4,
			#offset = 1,
			font = text_font,
			cex = f_size,
			col = "black"
		)
	}

if ( exists("target_words") ){
	if ( is.null(target_ids) == FALSE){
		rect(
			lay_f[target_ids,1] - rect_size, lay_f[target_ids,2] - rect_size,
			lay_f[target_ids,1] + rect_size, lay_f[target_ids,2] + rect_size,
		)
	}
}


if(0){
if (com_method == "twomode_g"){
# ���դ��ץ�åȴؿ�������
s.label_my <- function (dfxy, xax = 1, yax = 2, label = row.names(dfxy),
    clabel = 1, 
    pch = 20, cpoint = if (clabel == 0) 1 else 0, boxes = TRUE, 
    neig = NULL, cneig = 2, xlim = NULL, ylim = NULL, grid = TRUE, 
    addaxes = TRUE, cgrid = 1, include.origin = TRUE, origin = c(0, 
        0), sub = "", csub = 1.25, possub = "bottomleft", pixmap = NULL, 
    contour = NULL, area = NULL, add.plot = FALSE) 
{
    dfxy <- data.frame(dfxy)
    opar <- par(mar = par("mar"))
    on.exit(par(opar))
    par(mar = c(0.1, 0.1, 0.1, 0.1))
    coo <- scatterutil.base(dfxy = dfxy, xax = xax, yax = yax, 
        xlim = xlim, ylim = ylim, grid = grid, addaxes = addaxes, 
        cgrid = cgrid, include.origin = include.origin, origin = origin, 
        sub = sub, csub = csub, possub = possub, pixmap = pixmap, 
        contour = contour, area = area, add.plot = add.plot)
    if (!is.null(neig)) {
        if (is.null(class(neig))) 
            neig <- NULL
        if (class(neig) != "neig") 
            neig <- NULL
        deg <- attr(neig, "degrees")
        if ((length(deg)) != (length(coo$x))) 
            neig <- NULL
    }
    if (!is.null(neig)) {
        fun <- function(x, coo) {
            segments(coo$x[x[1]], coo$y[x[1]], coo$x[x[2]], coo$y[x[2]], 
                lwd = par("lwd") * cneig)
        }
        apply(unclass(neig), 1, fun, coo = coo)
    }
    if (clabel > 0) 
        scatterutil.eti(coo$x, coo$y, label, clabel, boxes)
    if (cpoint > 0 & clabel < 1e-06) 
        points(coo$x, coo$y, pch = pch, cex = par("cex") * cpoint)
    #box()
    invisible(match.call())
}
library(ade4)

s.label_my(
	lay_f[var_select,],
	xax=1,
	yax=2,
	label=colnames(d)[ as.numeric( get.vertex.attribute(n2,"name") ) ][var_select],
	boxes=T,
	clabel=0.8,
	addaxes=F,
	include.origin=F,
	grid=F,
	cpoint=0,
	cneig=0,
	cgrid=0,
	add.plot=T,
)
}
}



}
'
}


1;