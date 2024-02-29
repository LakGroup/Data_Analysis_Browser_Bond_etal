function shape_classification_pca_analysis(data)
parameters = data.classes(:,2);
parameters = vertcat(parameters{:});
parameters = zscore(parameters);

pairwise_correlatioin = corr(parameters,parameters);
figure()
set(gcf,'color','w')
imagesc(pairwise_correlatioin);
xlabel('Parameters')
ylabel('Parameters')
colorbar()
colormap(hot)
set(gca,'color','w','box','on','boxstyle','full') 
title('pairwise correlation between features','interpreter','latex','fontsize',18)


figure()
set(gcf,'color','w')
for i=1:3
  for j=1:i-1
     subplot(2,2,(i-1)+2*(j-1))
     scatter(parameters(:,i),parameters(:,j),7,'b','filled')
     xlabel(sprintf('X%g',i)) 
     ylabel(sprintf('X%g',j))
     set(gca,'color','w','box','on','boxstyle','full')
  end
end

[w,pca_parameters,~,~,explained] = pca(parameters);

% figure()
% set(gcf,'color','w')
% for i=1:size(parameters,2)
%     varlabels{i} = ['X',num2str(i)];
% end
% biplot(w(:,1:2),'Scores',pca_parameters(:,1:2),'Varlabels',varlabels);
% set(gca,'color','w','box','on','boxstyle','full')

figure()
set(gcf,'color','w')
for i=1:3
  for j=1:i-1
     subplot(2,2,(i-1)+2*(j-1))
     scatter(pca_parameters(:,i),pca_parameters(:,j),7,'b','filled')
     xlabel(sprintf('PCA%g',i)) 
     ylabel(sprintf('PCA%g',j))
     set(gca,'color','w','box','on','boxstyle','full')
  end
end
figure()
pareto(explained) 
xlabel('Principal Component')
ylabel('Variance Explained (%)')

% disp('Calculating silhouette value for k-means clustering')
% kmeans_evaluation = evalclusters(pca_parameters,'kmeans','silhouette','klist',(1:100));
% clf(figure(1))
% plot(kmeans_evaluation)
% title('k-means clustering','interpreter','latex','fontsize',18)
% set(gcf,'color','w')
% set(gca,'color','w','box','on','boxstyle','full')
end