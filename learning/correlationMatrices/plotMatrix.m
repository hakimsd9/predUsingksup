function plotMatrix(M,labels);

imagesc(M)
colorbar
set(gca,'XTick',[1:size(M,1)],'YTick',[1:size(M,1)],'YTickLabel',labels,...
'Fontsize',6);
set(gca,'XTickLabel',labels)
xticklabel_rotate90(get(gca,'XTick'),labels);

end

