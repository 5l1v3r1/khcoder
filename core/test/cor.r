d <- NULL
d <- matrix( c(1,510,183,48,0,42,13,1,32,16,12,16,14,24,27,18,14,22,14,24,58,45,0,78,66,75,59,58,43,38,40,35,27,28,33,36,18,19,33,18,17,9,7,12,23,18,9,30,25,32,48,69,22,41,34,23,10,24,20,24,24,15,20,15,3,18,19,2,12,19,
2,85,7,41,0,27,39,0,9,15,7,6,10,7,25,32,18,4,28,1,27,19,0,48,30,44,36,26,38,20,18,24,18,11,24,7,11,28,8,23,10,10,14,4,0,2,24,28,11,14,186,31,111,21,20,16,0,28,5,12,10,14,8,10,2,1,14,57,15,6,
3,2,198,175,168,57,22,69,29,30,38,32,54,36,10,8,21,28,32,29,78,75,411,170,129,100,90,71,50,72,60,43,52,53,32,44,50,28,30,21,31,38,33,38,30,32,18,33,26,35,35,82,37,73,69,67,94,41,52,37,37,41,42,43,63,47,32,3,33,34), byrow=T, nrow=3, ncol=70 )
row.names(d) <- c("��Q�搶�Ǝ�","���Q���e�Ǝ�","���Q�搶�ƈ⏑")
d <- d[,-1]
colnames(d) <- c("�搶","������","����","���삳��","���t","�莆","�f��","�l��","�l�q","�S��","�ԓx","�b","�Ӗ�","�a�C","����","�Ԏ�","�}","����","���","�O","��","�j","�v��","����","����","�o��","�A��","����","�l����","�m��","�s��","����","������","����","������","�m���","����","����","�o��","�b��","���","����","�t��","�΂�","����","�ǂ�","�D��","����","����","��","�l","��","��","��","�S","��","��","��","��","��","��","��","��","��","�j","�C","�Z","��","�O")
doc_length_mtr <- matrix( c( 49567.5,32624,25368,17054,86129,56698), ncol=2, byrow=T)
colnames(doc_length_mtr) <- c("length_c", "length_w")
v_count <- 0
v_pch   <- NULL

		if ( length(v_pch) == 0 ) {
			v_pch   <- 3
			v_count <- 1
		}
	doc_length_mtr <- subset(doc_length_mtr, rowSums(d) > 0)
d              <- subset(d,              rowSums(d) > 0)
n_total <- doc_length_mtr[,2]
d <- t(d)
d <- subset(d, rowSums(d) > 0)
d <- t(d)
# END: DATA
d_x <- 1
d_y <- 2
flt <- 0
flw <- 60
biplot <- 1
name_dim <- '����'
name_eig <- '�ŗL�l'
name_exp <- '��^��'
library(MASS)

# Filter words by chi-square value �����{��R�����g
if ( (flw > 0) && (flw < ncol(d)) ){
	sort  <- NULL
	for (i in 1:ncol(d) ){
		# print( paste(colnames(d)[i], chisq.test( cbind(d[,i], n_total - d[,i]) )$statistic) )
		sort <- c(
			sort, 
			chisq.test( cbind(d[,i], n_total - d[,i]) )$statistic
		)
	}
	d <- d[,order(sort,decreasing=T)]
	d <- d[,1:flw]
	d <- subset(d, rowSums(d) > 0)
}

c <- corresp(d, nf=min( nrow(d), ncol(d) ) )

# Dilplay Labels only for distinctive words
if ( (flt > 0) && (flt < nrow(c$cscore)) ){
	sort  <- NULL
	limit <- NULL
	names <- NULL
	ptype <- NULL
	
	# compute distance from (0,0)
	for (i in 1:nrow(c$cscore) ){
		sort <- c(sort, c$cscore[i,d_x] ^ 2 + c$cscore[i,d_y] ^ 2 )
	}
	
	# Put labels to top words
	limit <- sort[order(sort,decreasing=T)][flt]
	for (i in 1:nrow(c$cscore) ){
		if ( sort[i] >= limit ){
			names <- c(names, rownames(c$cscore)[i])
			ptype <- c(ptype, 1)
		} else {
			names <- c(names, NA)
			ptype <- c(ptype, 2)
		}
	}
	rownames(c$cscore) <- names;
} else {
	ptype <- 1
}

pch_cex <- 1
if ( v_count > 1 ){
	pch_cex <- 1.25
}

k <- c$cor^2
txt <- cbind( 1:length(k), round(k,4), round(100*k / sum(k),2) )
colnames(txt) <- c(name_dim,name_eig,name_exp)
print( txt )
k <- round(100*k / sum(k),2)
plot(cb <- rbind(cbind(c$cscore[,d_x], c$cscore[,d_y], ptype),cbind(c$rscore[,d_x], c$rscore[,d_y], v_pch)),pch=c(20,1,0,2,4:15)[cb[,3]],col=c("#66CCCC","#ADD8E6",rep( "#DC143C", v_count ))[cb[,3]],xlab=paste(name_dim,d_x," (",k[d_x],"%)",sep=""),ylab=paste(name_dim,d_y," (",k[d_y],"%)",sep=""),cex=c(1,1,rep( pch_cex, v_count ))[cb[,3]], )
library(maptools)
labcd <- pointLabel(x=c(c$cscore[,d_x], c$rscore[,d_x]),y=c(c$cscore[,d_y], c$rscore[,d_y]),labels=c(rownames(c$cscore),rownames(c$rscore)),cex=1,offset=0,doPlot=F)


#------------------------------------------------------------------------------
# packages: wordcloud, Rcpp, slam
if (T){
xorg <- c(c$cscore[,d_x], c$rscore[,d_x])
yorg <- c(c$cscore[,d_y], c$rscore[,d_y])
cex  <- 1

library(wordcloud)
nc <- wordlayout(
	labcd$x,
	labcd$y,
	rownames(cb),
	cex=cex * 1.25,
	xlim=c(  par( "usr" )[1], par( "usr" )[2] ),
	ylim=c(  par( "usr" )[3], par( "usr" )[4] )
)

xlen <- par("usr")[2] - par("usr")[1]
ylen <- par("usr")[4] - par("usr")[3]

for (i in 1:length(rownames(cb)) ){
	x <- ( nc[i,1] + .5 * nc[i,3] - labcd$x[i] ) / xlen
	y <- ( nc[i,2] + .5 * nc[i,4] - labcd$y[i] ) / ylen
	d <- sqrt( x^2 + y^2 )
	if ( d > 0.05 ){
		# print( paste( rownames(cb)[i], d ) )
		
		segments(
			nc[i,1] + .5 * nc[i,3], nc[i,2] + .5 * nc[i,4],
			xorg[i], yorg[i],
			col="gray60",
			lwd=1
		)
		
	}
}

xorg <- labcd$x
yorg <- labcd$y
labcd$x <- nc[,1] + .5 * nc[,3]
labcd$y <- nc[,2] + .5 * nc[,4]
}
#------------------------------------------------------------------------------

#labcd$x <- xorg
#labcd$y <- yorg


text(labcd$x, labcd$y, rownames(cb),cex=1,offset=0,col=c("black",NA,rep("#FF6347",v_count) )[cb[,3]])
