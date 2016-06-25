capture prog drop thresholdtest
program define thresholdtest,rclass
    version 13.0
    syntax varlist(numeric) [if] [in] [,q(varname) trim_per(real .15) rep(integer 2000)]
    capture drop qs_test lr_test clr_test
    marksample touse
    mata:dat=st_data(.,"`varlist'")
	mata:q=st_data(.,"`q'")
    mata:trim_per=`trim_per'
    mata:rep=`rep'
    mata:m_thrtest(dat,q,trim_per,rep)
    label var lr_test "F(Gamma)"
    label var clr_test "95% Critical"
    label var qs_test "Threshold Values"
    line lr_test clr_test qs_test,ytitle("F(Gamma") xtitle("Gamma") title("F Test for Threshold Reject Linearity if F Sequence Exceeds Critical Value",size(small))
end

capture mata drop m_thrtest()
version 13.0
mata:
void m_thrtest(real matrix dat, real matrix q, real scalar trim_per, real scalar rep)
{
n=length(dat[,1]);
qs=0;
cr_=0.95;
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
qs=uniqrows(q);
qn=rows(qs);
qq=J(qn,1,1);
r=1;

for (r=1;r<=qn;r++){
   qq[r]=sum(q:==qs[r])
}

cqq=qq;
for(r=2;r<=length(qq);r++){
cqq[r]=sum(qq[1::r])
}

sq=(cqq:>=floor(n*trim_per)):*(cqq:<=floor(n*(1-trim_per)))
temp_qs=0;temp_cqq=0;ind=0;

for (i=1;i<=length(sq);i++){
   if (sq[i]==1){
      if (ind==0){
	  
      temp_qs=qs[i]
	  temp_cqq=cqq[i]
	  ind=1;
      }
	  else {
	  temp_qs=(temp_qs\qs[i])
	  temp_cqq=(temp_cqq\cqq[i])
	  }
	}  
}
qs=temp_qs;
cqq=temp_cqq;
qn=length(qs);

mi=luinv(x'*x);
e=y-x*mi*(x'*y);
ee=e'*e;
xe=x:*(e*J(1,length(x[1,]),1));
vi=xe'*xe;
cxe=xe;

for(r=2;r<=rows(xe);r++){
cxe[r,]=colsum(xe[1::r,])
}
sn=J(qn,1,0);
    cqqb=1;
    mm=J(k,k,0);
    vv=J(k,k,0);
    r=1;
	   while (r<=qn){
        cqqr=cqq[r];
        mm=mm+x[cqqb::cqqr,]'*x[cqqb::cqqr,];
        vv=vv+xe[cqqb::cqqr,]'*xe[cqqb::cqqr,];
        sume=cxe[cqqr,]';
        mmi=luinv(vv - mm*mi*vv - vv*mi*mm + mm*mi*vi*mi*mm);
        sn[r]=sume'*mmi*sume;
        cqqb=cqqr+1;
				r=r+1;
		}	
		
    for (i=1;i<=length(sn);i++){
        if (sn[i]:==max(sn)){
            si=i;
            break;
        }
    }	
    qmax=qs[si];
    lr=sn;
    ftest=sn[si];
    fboot=J(rep,1,0); 
    j=1;
    while (j<=rep){
        y=rnormal(n,1,0,1):*e;
        xe=x:*((y-x*mi*(x'*y))*J(1,length(x[1,]),1));
        vi=xe'*xe;
        cxe=xe;

        for(r=2;r<=rows(xe);r++){
        cxe[r,]=colsum(xe[1::r,])
        }
        
		sn=J(qn,1,0);
        cqqb=1;
        mm=J(k,k,0);
        vv=J(k,k,0);
        r=1;
        while (r<=qn) {
            cqqr=cqq[r];
            mm=mm+x[cqqb::cqqr,]'*x[cqqb::cqqr,];
            vv=vv+xe[cqqb::cqqr,]'*xe[cqqb::cqqr,];
            sume=cxe[cqqr,]';
            mmi=vv - mm*mi*vv - vv*mi*mm + mm*mi*vi*mi*mm;
            temp_sum=luinv(mmi)*sume;
                sm=luinv(mmi)*sume;
                sn[r]=sume'*sm;
           
            cqqb=cqqr+1;
            r=r+1;
        }		
        fboot[j]=max(sn)';
        j++
    }
fboot1=sort(fboot,1);
pv=mean(fboot1:>=ftest)';
cr=fboot1[round(rep*cr_)];
clr=J(qn,1,1)*cr;
printf(" \n");
printf(" \n");
printf("Test of Null of No Threshold Against Alternative of Threshold\n")
printf("Allowing Heteroskedastic Errors (White Corrected)\n")
printf(" \n");
printf("______________________________________________________________________\n");
printf("Number of Bootstrap Replications:  %f\n",rep);
printf("Trimming Percentage:               %f\n",trim_per);
printf(" \n");
printf("Threshold Estimate:               %f\n",qmax);
printf("LM-test for no threshold:         %f\n",ftest);
printf("Bootstrap P-Value:                %f\n",pv);
printf("______________________________________________________________________\n");

temp=st_addvar("double","qs_test")
temp=st_addvar("double","lr_test")
temp=st_addvar("double","clr_test")

st_store(.,"qs_test",qs\J(st_nobs()-rows(qs),1,.))
st_store(.,"lr_test",lr\J(st_nobs()-rows(lr),1,.))
st_store(.,"clr_test",clr\J(st_nobs()-rows(clr),1,.))
}
end
