# Tk�v���b�g�Ŕ������\�ȋ��N�l�b�g���[�N�̍쐬
# �����N�l�b�g���[�N�쐬����Ɏ��s

tkid <- tkplot(
	n2,
	vertex.label       =colnames(d)
	                    [ as.numeric( get.vertex.attribute(n2,"name") ) ],
	#vertex.color       =ccol,
	#vertex.frame.color =com_col_v,
	vertex.size        =22,
	#vertex.shape       =v_shape,
	edge.color         ="gray35",
	#edge.lty           =edg_lty,
	#edge.width         =edg_width,
	layout             =lay_f,
	rescale            =F
)
