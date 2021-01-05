function  [y] = lagsMulti(data,k)
y = [];
for j = 1:k
    y = [y data(k-j+1:end-j,:)];
end
