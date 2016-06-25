capture prog drop thresholdreg
program define thresholdreg,rclass
    version 13.0
    syntax varlist(numeric) [if] [in] [,q(varname) h(integer 1)]
	forval i=1/`=length("`varlist'")' {
		local name`i'=word("`varlist'",`i')
	}
    capture drop qs_est lr_est clr_est
    marksample touse
    mata:dat=st_data(.,"`varlist'")
	mata:q=st_data(.,"`q'")
    mata:h=`h'
    mata:m_threst(dat,q,h)
    label var lr_est "LR(Gamma)"
    label var clr_est "95% Critical"
    label var qs_est "Threshold Values"
    line lr_est clr_est qs_est,ytitle("Likelihood Ratio Sequence in Gamma") xtitle("Threshold Variable") title("Confidence Interval Construction for Threshold")
end

capture mata drop m_threst()
version 13.0
mata:
void m_threst(real matrix dat, real matrix q, real scalar h)
{
conf1_=.95
conf2_=.8;
nonpar_=2;
graph_=1;

n=length(dat[,1]);

qs=0;
for (i=1;i<=length(q);i++){
    for (i_=1; i_<=length(q);i_++){
	    temp=0;
		for (j=1; j<=length(q);j++){
		if ((q[i_]>q[j])|(i_>=j&q[i_]==q[j])){
		temp=temp+1;
		}
	    }
	if (temp==i){
	    qs=(qs\i_);
	}
  }
}	


qs=qs[2::length(qs)];
q=q[qs];
qnew=q[qs];
newdat=dat[qs,.]
y=newdat[.,1];
x=(J(n,1,1),newdat[.,2::cols(newdat)]);
k=cols(newdat);

mi=luinv(x'*x);
beta=mi*(x'*y);
e=y-x*beta;
ee=e'*e;
sig=ee/(n-k);
xe=x:*(e*J(1,length(x[1,]),1));

if (h==0) {
    se=sqrt(diag(mi):*sig)
	se=diagonal(se);
	}
else if (h==1){
    se=sqrt(diag(mi*xe'*xe*mi));
	se=diagonal(se);
     }

vy=colsum((y:-mean(y)'):*(y:-mean(y)'))';
r_2=1-ee/vy;

qs=uniqrows(q);
qn=rows(qs);
sn=J(qn,1,0);

irb=J(n,1,0);
mm=J(k,k,0);
sume=J(k,1,0);
ci=0;

r=1;
while (r<=qn){
    irf=(q:<=qs[r]);
    ir=irf-irb;
    irb=irf;
    ci=ci+colsum(ir)';
    xir=x[1,];
    temp=0;
    for (i=1;i<=length(ir);i++){
        if (ir[i]==1){
            if (temp==0){
                xir=x[i,];
                temp=1
				}
            else		{
                xir=(xir\x[i,]);
            }
        }
    }
    mm=mm+xir'*xir;
    sume=sume+(ir'*xe)';
    mmi=mm-mm*mi*mm;
	
    if ((ci>k+1)*(ci<(n-k-1))){
        sn[r]=ee-sume'*(luinv(mmi)*sume);
		}
    else
	    {
        sn[r]=ee;
    }
    r++
}

for (i=1;i<=length(sn);i++) {
    if (sn[i]==min(sn)){
        rmin=i;
        break;
    }
}

smin=sn[rmin];
qhat=qs[rmin];
sighat=smin/n;

i1=(q:<=qhat);
i2=1:-i1;

x1=0;y1=0;x2=0;y2=0;ind1=0;ind2=0;

for (i=1;i<=length(i1);i++){
    if (i1[i]==1){

	    if (ind1==0) {
            x1=x[i,];
            y1=y[i,];
            ind1=1;
			}
        else {
            x1=(x1\x[i,]);
            y1=(y1\y[i,]);
        }
	}	
    else  {
    	 if (ind2==0) {
         x2=x[i,];
         y2=y[i,];
         ind2=1;
			}
		
        else {
            x2=(x2\x[i,]);
            y2=(y2\y[i,]);
        }
    }
 }
 
mi1=luinv(x1'*x1);
mi2=luinv(x2'*x2);
beta1=mi1*(x1'*y1);
beta2=mi2*(x2'*y2);
e1=y1-x1*beta1;
e2=y2-x2*beta2;
ej=(e1\e2);
n1=length(y1[,1]);
n2=length(y2[,1]);
ee1=e1'*e1;
ee2=e2'*e2;
sig1=ee1/(n1-k);
sig2=ee2/(n2-k);
sig_jt=(ee1+ee2)/(n-2*k);

 if (h==0){
    se1=sqrt(diag(mi1)*sig_jt);
    se2=sqrt(diag(mi2)*sig_jt);
	}
 else if (h==1){
    se1=sqrt(diag(mi1*(x1:*(e1*(J(1,length(x1[1,]),1))))'*(x1:*(e1*(J(1,length(x1[1,]),1))))*mi1));
	se2=sqrt(diag(mi2*(x2:*(e2*(J(1,length(x2[1,]),1))))'*(x2:*(e2*(J(1,length(x2[1,]),1))))*mi2));
	}
	

	se1=diagonal(se1);
    se2=diagonal(se2);

  
vy1=sum((y1:-mean(y1)'):*(y1:-mean(y1)'))';
vy2=sum((y2:-mean(y2)'):*(y2:-mean(y2)'))';
r2_1=1-ee1/vy1;
r2_2=1-ee2/vy2;
r2_joint=1-(ee1+ee2)/vy;

if (h==0){
    lr=(sn:-smin):/sighat
	}
 else {
    r1=(x*(beta1-beta2)):^2;
	r2=r1:*((ej:*ej)*J(1,length(r1[1,]),1));
    qx=(q:^0,q:^1,q:^2);
    qh=(qhat:^0,qhat:^1,qhat:^2);
    m1=luinv(qx'*qx)*qx'r1;
    m2=luinv(qx'*qx)*qx'r2;
    g1=qh*m1;
    g2=qh*m2;
  
    if (nonpar_==2){
        sigq=sqrt(mean((q:-mean(q)'):^2));
        hband=2.344*sigq/(n^(.2));
        u=(qhat:-q):/hband;
        u2=u:^2;
        f=mean((1:-u2):*(u2:<=1))'*(0.75/(hband^2));
        df=-mean((1:-u2):*(u2:<=1))'*(1.5/(hband^2));
        eps=r1-qx*m1;
        sige=(eps'*eps)/(n-3);
        hband=sige/(4*f*((m1[3]+(m1[2]+2*m1[3]*qhat)*df/f)^2));
        u2=((qhat:-q)/hband):^2;
        kh=((1:-u2)*.75/hband):*(u2:<=1);
        g1=mean(kh:*r1);
        g2=mean(kh:*r2);
    }
    eta2=g2/g1;
    lr=(sn:-smin)/eta2;
}

c1=-2*log(1-sqrt(conf1_));
c2=-2*log(1-sqrt(conf2_));
lr1=(lr:>=c1);
lr2=(lr:>=c2);

if (max(lr1)==1) {
    minind_lr1=0;
    for (i=1;i<=length(lr1);i++){
        if (lr1[i]==min(lr1)) {
            minind_lr1=i;
            break;
        }
    }
    qhat1=qs[minind_lr1];
    minind_lr1v=0;
    for (i=1;i<=length(lr1);i++){
        if (lr1[qn+1-i]==min(lr1)){
            minind_lr1v=i;
            break;
        }
    }
    qhat2=qs[qn+1-minind_lr1v];
	}
	
else {
    qhat1=qs[1];
    qhat2=qs[qn];
}


temp1=(normal(((1::300):/100))*2:-1)
temp=(temp1:>=conf1_);

for (i=1;i<=length(temp);i++){
    if (temp[i]:==max(temp)){
        z=i/100;
        break;
    }
}


beta1l=beta1-se1*z;
beta1u=beta1+se1*z;
beta2l=beta2-se2*z;
beta2u=beta2+se2*z;

r=1;
while (r<=qn){
    if (lr2[r]==0){
        i1=(q:<=qs[r]);
        x1=0;y1=0;ind1=0;
        for (i=1;i<=length(i1);i++){
            if (i1[i]==1){
			
                if (ind1==0){
                    x1=x[i,];
                    y1=y[i,];
                    ind1=1
					}
					
                else {
                    x1=(x1\x[i,]);
                    y1=(y1\y[i,]);
                }
            }
        }
		
        if (det(x1'*x1)>0) {
            mi1=luinv(x1'*x1);
            b1=mi1*(x1'*y1);
            e1=y1-x1*b1;
            if (h==0) {

                ser1=sqrt(diag(mi1)*(e1'*e1):/(length(y1[,1])-k))
				}
            else {
           ser1=sqrt(diag(mi1*(x1:*(e1*J(1,length(x1[1,]),1)))'*(x1:*(e1*J(1,length(x1[1,]),1)))*mi1));
                    }
			ser1=diagonal(ser1);
            beta1l=colmin((beta1l'\(b1-ser1*z)'))';
            beta1u=colmax((beta1u'\(b1+ser1*z)'))';
        }
		
        i2=1:-i1;
        x2=0;y2=0;ind2=0;
		
        for (i=1;i<=length(i2);i++){
            if (i2[i]==1){
                if (ind2==0) {
                    x2=x[i,];
                    y2=y[i,];
                    ind2=1
					}
                else {
                    x2=(x2\x[i,]);
                    y2=(y2\y[i,]);
                }
            }
        }
		
        if (det(x2'*x2)>0) {
            mi2=luinv(x2'*x2);
            b2=mi2*(x2'*y2);
            e2=y2-x2*b2;
           if (h==0) {
                ser2=sqrt(diag(mi2)*(e2'*e2):/(length(y2[,1])-k))
				}
            else {
			    ser2=sqrt(diag(mi2*(x2:*(e2*J(1,length(x2[1,]),1)))'*(x2:*(e2*J(1,length(x2[1,]),1)))*mi2));
            }
			ser2=diagonal(ser2)
            beta2l=colmin((beta2l'\(b2-ser2*z)'))';
            beta2u=colmax((beta2u'\(b2+ser2*z)'))';
        }
	 }
    r++
}

e2=ej:*ej;
x2=x:*x;
v=e2-x2*luinv(x2'*x2)*x2'*e2;
e2=e2:-mean(e2);
te=length(e)*(1-(v'*v):/(e2'*e2));
ht=chi2tail(length(x[1,]),te);

printf("Global OLS Estimation, Without Threshold\n");
printf("______________________________________________________________________\n");
if (h==1) {
    printf("Heteroskedasticity Correction Used\n")
	}
	
else if (h==0){
    printf("OLS Standard Errors Reported\n")
	}
printf("______________________________________________________________________\n");
printf("Independent Variables         Estimate                St Error\n");
printf("______________________________________________________________________\n");
printf("Intercept                    %f               %f\n",beta[1],se[1]);
for (i=2;i<=length(beta);i++) {
	name=st_local(sprintf("name%f",i))
    printf("%s                        %f               %f\n",name,   beta[i], se[i]);
}

printf("\n");
printf("Observations:                      %f\n",n);
printf("Degrees of Freedom:                %f\n",n-k);
printf("Sum of Squared Errors:             %f\n",ee);
printf("Residual Variance:                 %f\n",sig);
printf("R-squared:                         %f\n",r_2);
printf("Heteroskedasticity Test (P-Value): %f\n",ht);
printf("\n");
printf("\n");
printf("Threshold Estimation\n");
printf("______________________________________________________________________\n");
printf("\n");
printf("Threshold Estimate:               %f\n",qhat);
printf(".%f Confidence Iterval:           [%f,%f]\n",conf1_*100,qhat1,qhat2);
printf("Sum of Squared Errors             %f\n",ee1+ee2);
printf("Residual Variance:                %f\n",sig_jt);
printf("Joint R-Squared:                  %f\n",r2_joint);
printf("Heteroskedasticity Test (p-value):%f\n",ht);
printf("\n");
printf("______________________________________________________________________\n");
printf("\n");
printf("Regime1     q<=%f\n",qhat);
printf("\n");
printf("Parameter Estimates\n");
printf("______________________________________________________________________\n");
printf("Independent Variables         Estimate                St Error\n");
printf("______________________________________________________________________\n");
printf("Intercept                    %f               %f\n",beta1[1],se1[1]);
for (i=2;i<=length(beta1);i++) {
	name=st_local(sprintf("name%f",i))
    printf("%s                        %f               %f\n",name,   beta1[i], se1[i]);
}

printf("\n");
printf(".%f Confidence Regions for Parameters.\n",conf1_*100);
printf("Independent Variables         Low                     High\n");
printf("______________________________________________________________________\n");

printf("Intercept                    %f             %f\n",beta1l[1],beta1u[1]);
for (i=2;i<=length(beta);i++) {
	name=st_local(sprintf("name%f",i))
 printf("%s                          %f            %f\n",name, beta1l[i],beta1u[i]);
}

printf("\n");
printf("Observations:                     %f\n",n1);
printf("Degrees of Freedom:               %f\n",n1-k);
printf("Sum of Squared Errors:            %f\n",ee1);
printf("Residual Variance:                %f\n",sig1);
printf("R-squared:                        %f\n",r2_1);
printf("\n");
printf("\n");

printf("Regime2    q>%f\n", qhat);
printf("\n");
printf("Parameter Estimates\n");
printf("______________________________________________________________________\n");
printf("Independent Variables         Estimate                St Error\n");
printf("______________________________________________________________________\n");
printf("Intercept                    %f               %f\n",beta2[1],se2[1]);
for (i=2;i<=length(beta2);i++) {
	name=st_local(sprintf("name%f",i))
    printf("%s                        %f               %f\n",name,   beta2[i], se2[i]);
}

printf("\n");
printf(".%f Confidence Regions for Parameters.\n",conf1_*100);
printf("Independent Variables         Low                      High\n");
printf("______________________________________________________________________\n");
printf("Intercept                     %f             %f\n",beta2l[1],beta2u[1]);
for (i=2;i<=length(beta);i++){
	name=st_local(sprintf("name%f",i))
printf("%s                           %f            %f\n",name,beta2l[i],beta2u[i]);
}

printf("\n");
printf("Observations:                     %f\n",n2);
printf("Degrees of Freedom:               %f\n",n2-k);
printf("Sum of Squared Errors:            %f\n",ee2);
printf("Residual Variance:                %f\n",sig2);
printf("R-squared:                        %f\n",r2_2);
clr=J(qn,1,1)*c1

temp=st_addvar("double","qs_est")
temp=st_addvar("double","lr_est")
temp=st_addvar("double","clr_est")

st_store(.,"qs_est",qs\J(st_nobs()-rows(qs),1,.))
st_store(.,"lr_est",lr\J(st_nobs()-rows(lr),1,.))
st_store(.,"clr_est",clr\J(st_nobs()-rows(clr),1,.))

}
end
