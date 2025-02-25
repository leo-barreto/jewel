C     program readfile
C     implicit none
C     write(*,*) 'Hello World!'
C     end program

C++   This is a library built to read external medium profiles ++
C++   for JEWEL                                                ++

C++   This is the main subroutine that performs the reading    ++
C++                                                            ++
      subroutine reader(filename,np,nt,timesteps,tprofile)
      implicit none
      integer i,j,k
      integer np,nt
      integer geti
      integer ios
      character*100 filename
      double precision timesteps(60)
      double precision tprofile(np,np,60)
      double precision ux(np,np,60)
      double precision uy(np,np,60)
      double precision t,x,y,temp,vx,vy
      integer linecounter

      open(unit=1,file=filename,iostat=ios)
      write(*,*) "Opening file: ",filename
      
      do k=2,60
      timesteps(k)=1.d20
      end do
      k=1
      timesteps(k)=0.d0

      linecounter=0
      do while (ios.eq.0)
      
      read(1,*,iostat=ios) t,x,y,temp,vx,vy
      i=geti(x,np)
      j=geti(y,np)

      linecounter=linecounter+1

      if(t.ne.timesteps(k)) then
      k=k+1
      timesteps(k)=t
      end if

      tprofile(i,j,k)=temp
      ux(i,j,k)=vx
      uy(i,j,k)=vy

      end do
      
      write(*,*) "File has ",linecounter, " lines"

      end subroutine

      integer function geti(x,np)
      implicit none
      integer np
      double precision x,xmin,xmax,dx
      
      xmax=25.d0
      xmin=-25.d0
      dx=(xmax-xmin)/(np-1)
      geti=1+(x-xmin)/dx
      end function

      integer function getk(t,timesteps)
      implicit none
      integer k
      double precision t
      double precision timesteps(60)
      t=0.d0
      getk=1
      do k=1,60

      if(timesteps(k).le.t) then
      getk=k
      endif

      enddo
      end function


      double precision function interpol(t,x,y,np,timesteps,tgrid)
      implicit none
      integer i,j,ii,jj,iii,jjj,np
      integer k,kk
      double precision timesteps(60)
      double precision tgrid(np,np,60),igrid(4,4),xgrid(4,4),ygrid(4,4)
      double precision xmax,xmin,dx,dt
      double precision t,x,y,xa,ya
      double precision f(2)
      double precision bicubic
      integer getk

      k=getk(t,timesteps)
      if(timesteps(k).eq.0.d0.and.timesteps(k+1).eq.0.d0) then
      dt=1e30
      else
      dt=timesteps(k+1)-timesteps(k)
      end if
      
      xmax=25.d0
      xmin=-25.d0
      dx=(xmax-xmin)/(np-1)

      i=1+floor((x-xmin)/dx)
      j=1+floor((y-xmin)/dx)
      xa=mod(x-xmin,dx)
      ya=mod(y-xmin,dx)

      do kk=1,2
      !write(*,*) "k:",k-1+kk
      do ii=1,4
            do jj=1,4
                  iii=i+ii-2
                  jjj=j+jj-2
                  if (iii.gt.np.or.iii.lt.1) then
                        igrid(ii,jj)=0.d0
                  else if (jjj.gt.np.or.jjj.lt.1) then
                        igrid(ii,jj)=0.d0
                  else if (k-1+kk.gt.59.or.k-1+kk.lt.1) then
                        igrid(ii,jj)=0.d0
                  else
                        igrid(ii,jj)=tgrid(iii,jjj,k-1+kk)
                  end if
                  xgrid(ii,jj)=xa+(ii-1)*dx
                  ygrid(ii,jj)=ya+(jj-1)*dx
            enddo
      enddo

      !write(*,*) "Calling bicubic with parameters:"
      !write(*,*) xa,ya,dx,xmin,xmax
      !write(*,*) "Temperature grid"
      !write(*,*) igrid(1,:)
      !write(*,*) igrid(2,:)
      !write(*,*) igrid(3,:)
      !write(*,*) igrid(4,:)
      !write(*,*) "X grid"
      !write(*,*) xgrid(1,:)
      !write(*,*) xgrid(2,:)
      !write(*,*) xgrid(3,:)
      !write(*,*) xgrid(4,:)
      !write(*,*) "Y grid"
      !write(*,*) ygrid(1,:)
      !write(*,*) ygrid(2,:)
      !write(*,*) ygrid(3,:)
      !write(*,*) ygrid(4,:)
      f(kk)=bicubic(xa,ya,dx,xmin,xmax,igrid,xgrid,ygrid)
      enddo

      !write(*,*) "Interpol=",interpol
      interpol=f(1)+(t-timesteps(k))*(f(2)-f(1))/dt
      end function
      
      double precision function bicubic(xa,ya,dx,xmin,xmax,igrid,xc,yc)
      implicit none
      integer i,j
      double precision y(2,2),y1(2,2),y2(2,2),y12(2,2)
      double precision igrid(4,4)
      double precision xc(4,4),yc(4,4),ansy
      double precision xa,ya,dx,xmin,xmax
      double precision dertwospline
      
      do i=1,2
            do j=1,2
                  y(i,j)=igrid(i+1,j+1)
                  y1(i,j)=(igrid(i+2,j+1)-igrid(i,j+1))/(xc(i+2,j+1)
     &-xc(i,j+1))
                  y2(i,j)=(igrid(i+1,j+2)-igrid(i+1,j))/(yc(i+1,j+2)
     &-yc(i+1,j))
                  y12(i,j)=(igrid(i+2,j+2)-igrid(i+2,j)-igrid(i,j+2)
     &+igrid(i,j))/(yc(i+1,j+2)-yc(i+1,j))*(xc(i+2,j+1)-xc(i,j+1))
            end do
      end do
      
      bicubic=dertwospline(xc(2:3,2:3),yc(2:3,2:3),y,y1,y2,y12,xa,ya)
      end function

      double precision function dertwospline(x1,x2,y,y1,y2,y12,xa,xb)
      implicit none
      integer i
      double precision x1(2,2)
      double precision x2(2,2)
      double precision y(2,2)
      double precision y1(2,2)
      double precision y2(2,2)
      double precision y12(2,2)
      double precision w(2),w1(2)
      double precision xa,xb
      double precision derspline

      w(1)=derspline(x1(:,1),y(:,1),y1(:,1),xa)
      w(2)=derspline(x1(:,2),y(:,2),y1(:,1),xa)
      w1(1)=derspline(x1(:,1),y2(:,1),y12(:,1),xa)
      w1(2)=derspline(x1(:,2),y2(:,2),y12(:,1),xa)
      
      dertwospline=derspline(x2(1,:),w(:),w1(:),xb)

      end function

      double precision function derspline(x,y,yprime,xval)
      implicit none
      integer i
      double precision x(2),y(2),yprime(2),c(4),yvec(4)
      double precision dx,xval,t
      double precision a(4,4)
      data a/1.d0,0.d0,-3.d0,2.d0,0.d0,0.d0,3.d0,-2.d0,0.d0,1.d0,
     &-2.d0,1.d0,0.d0,0.d0,-1.d0,1.d0/

      dx=x(2)-x(1)
      do i=1,2
            yvec(i)=y(i)
            yvec(i+2)=dx*yprime(i)
      end do
      c=matmul(a,yvec) 

      t=(xval-x(1))/dx

      derspline=0.d0
      do i=1,4
      derspline=derspline+c(i)*t**(i-1)
      end do

      end function
