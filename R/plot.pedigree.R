# Automatically generated from all.nw using noweb
plot.pedigree <- function(x, id = x$id, status = x$status, 
                          affected = x$affected, age = NULL, number = NULL,     # Afegeixo age = NULL i number = NULL
                          cex = 1, col = 1, dist_text = 1.5,      # Afegeixo dist_text = 1.5
                          symbolsize = 1, branch = 0.6,       
                          packed = TRUE, align = c(1.5,2), width = 8, height = 4,   # Afegeixo height = 4
                          density = -1, mar=c(4.1, 1, 4.1, 1),    # Canvio a density = -1
                          angle = 45, keep.par=FALSE,          # Canvio a angle = 45
                          subregion, pconnect=.5, consultand = NULL, info = NULL,      # Afegeixo consultand = NULL i info = NULL
                          adopted = NULL, ...)     # Afegeixo adopted = NULL
{
    Call <- match.call()
    n <- length(x$id)        
    if(is.null(status))
      status <- rep(0, n)
    else {
        if(!all(status == 0 | status == 1 | status == 2))   # Afegeixo | status == 2 (embaràs)
          stop("Invalid status code")
        if(length(status) != n)
          stop("Wrong length for status")
    }
    if(!missing(id)) {
        if(length(id) != n)
          stop("Wrong length for id")
    }
    if(is.null(affected)){
      affected <- matrix(0,nrow=n)
    }
    else {
        if (is.matrix(affected)){
            if (nrow(affected) != n) stop("Wrong number of rows in affected")
            if (is.logical(affected)) affected <- 1* affected
            
            # Afegeixo comprovació de density i angle
            if (ncol(affected) != length(angle) || ncol(affected) != length(density))
                stop("Number of angle/density values must be equal to number of columns of affected")
        } 
        
        else {
            if (length(affected) != n)
                stop("Wrong length for affected")

            if (is.logical(affected)) affected <- as.numeric(affected)
            if (is.factor(affected))  affected <- as.numeric(affected) -1
        }
        if(max(affected, na.rm=TRUE) > min(affected, na.rm=TRUE)) {
          affected <- matrix(affected - min(affected, na.rm=TRUE),nrow=n)
         ## affected[is.na(affected)] <- -1
        } else {
          affected <- matrix(affected,nrow=n)
        }
        ## JPS 4/28/17 bug fix b/c some cases NAs are not set to -1
        affected[is.na(affected)] <- -1
        if (!all(affected == 0 | affected == 1 | affected == -1 | affected == 2 | affected == 3))    # Afegeixo | affected == 2 | affected == 3 (portadors i presimptomàtics)
                stop("Invalid code for affected status")
    }

    
    # Canvio les comprovacions de l'argument col (color)
    if (length(col) != ncol(affected)) stop("col argument must have length equal to number of columns of affected")
    
    # Afegeixo comprovació de consultand
    if (!is.null(consultand)) {
      `%notin%` = Negate(`%in%`)
      for (i in 1:length(consultand)){
        if (consultand[i] %notin% x$id)
          stop("Consultand id does not correspond to any of the family members")
      }
    }
    
    # Afegeixo comprovació de age
    if (!is.null(age)) {
      if (length(age) != n) {
        stop("Wrong length for age")
      }
    }
    
    # Afegeixo comprovació de number
    if (!is.null(number)) {
      if (length(number) != n) {
        stop("Wrong length for number of people")
      }
      if (!all(number == 1 | number == 2 | number == 3 | number == 4 | number == 5 | number == 6 | number == 7 | number == 8 | number == 9 | number == "n")) {
        stop("Wrong value for number of people")
      }
    }
    
    # Afegeixo comprovació de info
    if (!is.null(info)) {
      if (nrow(info) != n) {
        stop("Wrong number of rows for information matrix")
      }
    }
    
    # Afegeixo comprovació de que si un individu presenta els valors 2 o 3 a affected (portadors) no pot estar
    # afectat per cap altre fenotip
    if (2 %in% affected | 3 %in% affected) {
      for (i in 1:nrow(affected)) {
        r <- affected[i,]
        if (2 %in% r | 3 %in% r) {
          c <- which(r == 2 | r == 3)[1]
          if (sum(abs(r[-c])) != 0) {
            stop("Carrier status can only be represented for an individual if this individual is not affected by any other phenotype")
          }
        }
      }
    }
    
    # Afegeixo comprovació de adopted
    if (!is.null(adopted)) {
      if (length(adopted) != n) {
        stop("Wrong length for adopted")
      }
      if (!all(is.na(adopted) | adopted == "in" | adopted == "out")) {
        stop("Wrong value for adopted status")
      }
    }
    
    
    

    
    subregion2 <- function(plist, subreg) {
        if (subreg[3] <1 || subreg[4] > length(plist$n)) 
            stop("Invalid depth indices in subreg")
        lkeep <- subreg[3]:subreg[4]
        for (i in lkeep) {
            if (!any(plist$pos[i,]>=subreg[1] & plist$pos[i,] <= subreg[2]))
                stop(paste("No subjects retained on level", i))
            }
        
        nid2 <- plist$nid[lkeep,]
        n2   <- plist$n[lkeep]
        pos2 <- plist$pos[lkeep,]
        spouse2 <- plist$spouse[lkeep,]
        fam2 <- plist$fam[lkeep,]
        if (!is.null(plist$twins)) twin2 <- plist$twins[lkeep,]
        
        for (i in 1:nrow(nid2)) {
            keep <- which(pos2[i,] >=subreg[1] & pos2[i,] <= subreg[2])
            nkeep <- length(keep)
            n2[i] <- nkeep
            nid2[i, 1:nkeep] <- nid2[i, keep]
            pos2[i, 1:nkeep] <- pos2[i, keep]
            spouse2[i,1:nkeep] <- spouse2[i,keep]
            fam2[i, 1:nkeep] <- fam2[i, keep]
            if (!is.null(plist$twins)) twin2[i, 1:nkeep] <- twin2[i, keep]

            if (i < nrow(nid2)) {  #look ahead
                tfam <- match(fam2[i+1,], keep, nomatch=0)
                fam2[i+1,] <- tfam
                if (any(spouse2[i,tfam] ==0)) 
                    stop("A subregion cannot separate parents")
                }
            }
        
        n <- max(n2)
        out <- list(n= n2[1:n], nid=nid2[,1:n, drop=F], pos=pos2[,1:n, drop=F],
                    spouse= spouse2[,1:n, drop=F], fam=fam2[,1:n, drop=F])
        if (!is.null(plist$twins)) out$twins <- twin2[, 1:n, drop=F]
        out
        }
    
    plist <- align.pedigree(x, packed = packed, width = width, align = align)
    if (!missing(subregion)) plist <- subregion2(plist, subregion)
    
    # Afegeixo comprovació de que el gràfic no es pot generar fins que no hi ha com a mínim 3 individus connectats
    if (all(plist$nid == 0)) stop("The plot can not be generated until at least 3 individuals are connected")
    
    xrange <- range(plist$pos[plist$nid >0])
    maxlev <- nrow(plist$pos)
    frame()
    oldpar <- par(mar=mar, pin=c(width-2, height), xpd=TRUE)    # Afegeixo pin=c(width-2, height) per a poder modificar tant l'amplada com l'alçada del gràfic
    psize <- par('pin')  # plot region in inches
    stemp1 <- strwidth("ABC", units='inches', cex=1)* 2.5/3     # Canvio cex=cex -> cex=1 per a que la mida dels símbols no es vegi afectada per la mida de la lletra
    stemp2 <- strheight('1g', units='inches', cex=1)            # Canvio cex=cex -> cex=1 per a que la mida dels símbols no es vegi afectada per la mida de la lletra
    stemp3 <- max(strheight(id, units='inches', cex=1))         # Canvio cex=cex -> cex=1 per a que la mida dels símbols no es vegi afectada per la mida de la lletra

    ht1 <- psize[2]/maxlev - (stemp3 + 1.5*stemp2)
    if (ht1 <=0) stop("Labels leave no room for the graph, reduce cex")
    ht2 <- psize[2]/(maxlev + (maxlev-1)/2)
    wd2 <- .8*psize[1]/(.8 + diff(xrange))

    boxsize <- symbolsize* min(ht1, ht2, stemp1, wd2) # box size in inches
    hscale <- (psize[1]- boxsize)/diff(xrange)  #horizontal scale from user-> inch
    vscale <- (psize[2]-(stemp3 + stemp2/2 + boxsize))/ max(1, maxlev-1)
    boxw  <- boxsize/hscale  # box width in user units
    boxh  <- boxsize/vscale   # box height in user units
    labh  <- stemp2/vscale   # height of a text string
    legh  <- min(1/4, boxh  *1.5)  # how tall are the 'legs' up from a child
    
    par(usr=c(xrange[1]- boxw/2, xrange[2]+ boxw/2, 
              maxlev+ boxh+ stemp3 + stemp2/2, 1))
    
    circfun <- function(nslice, n=50) {
        nseg <- ceiling(n/nslice)  #segments of arc per slice
        
        theta <- -pi/2 - seq(0, 2*pi, length=nslice +1)
        out <- vector('list', nslice)
        for (i in 1:nslice) {
            theta2 <- seq(theta[i], theta[i+1], length=nseg)
            out[[i]]<- list(x=c(0, cos(theta2)/2),
                            y=c(0, sin(theta2)/2) + .5)
            }
        out
    }
    
    polyfun <- function(nslice, object) {
        # make the indirect segments view
        zmat <- matrix(0,ncol=4, nrow=length(object$x))
        zmat[,1] <- object$x
        zmat[,2] <- c(object$x[-1], object$x[1]) - object$x
        zmat[,3] <- object$y
        zmat[,4] <- c(object$y[-1], object$y[1]) - object$y

        # Find the cutpoint for each angle
        #   Yes we could vectorize the loop, but nslice is never bigger than
        # about 10 (and usually <5), so why be obscure?
        ns1 <- nslice+1
        theta <- -pi/2 - seq(0, 2*pi, length=ns1)
        x <- y <- double(ns1)
        for (i in 1:ns1) {
            z <- (tan(theta[i])*zmat[,1] - zmat[,3])/
                (zmat[,4] - tan(theta[i])*zmat[,2])
            tx <- zmat[,1] + z*zmat[,2]
            ty <- zmat[,3] + z*zmat[,4]
            inner <- tx*cos(theta[i]) + ty*sin(theta[i])
            indx <- which(is.finite(z) & z>=0 &  z<=1 & inner >0)
            if (length(indx) > 1) indx <- indx[1]     # Afegeixo aquesta condicio per a que no doni error al generar el triangle
            x[i] <- tx[indx]
            y[i] <- ty[indx]
            }
        nvertex <- length(object$x)
        temp <- data.frame(indx = c(1:ns1, rep(0, nvertex)),
                           theta= c(theta, object$theta),
                           x= c(x, object$x),
                           y= c(y, object$y))
        temp <- temp[order(-temp$theta),]
        out <- vector('list', nslice)
        for (i in 1:nslice) {
            rows <- which(temp$indx==i):which(temp$indx==(i+1))
            out[[i]] <- list(x=c(0, temp$x[rows]), y= c(0, temp$y[rows]) +.5)
            }
        out
        }
    
    
    # Elimino: if (ncol(affected)==1) {
    polylist <- list(
        square = list(list(x=c(-1, -1, 1, 1)/2,  y=c(0, 1, 1, 0))),
        circle = list(list(x=.5* cos(seq(0, 2*pi, length=50)),
                           y=.5* sin(seq(0, 2*pi, length=50)) + .5)),
        diamond = list(list(x=c(0, -.5, 0, .5), y=c(0, .5, 1, .5))),
        triangle= list(list(x=c(0, -.56, .56),  y=c(0, 0.82, 0.82))))    # Canvio coordenades y per a que la punta del triangle estigui a dalt
    #    }
    # else {
    
    # Afegeixo aquest condicional if i el loop for
    if (ncol(affected) != 1) {
        polylistD <- list()
        for (i in 2:ncol(affected)) {
          square <- polyfun(i, list(x=c(-.5, -.5, .5, .5), y=c(-.5, .5, .5, -.5),
                                    theta= -c(3,5,7,9)* pi/4))
          circle <- circfun(i)
          diamond <- polyfun(i, list(x=c(0, -.5, 0, .5), y=c(-.5, 0, .5,0),
                                     theta= -(1:4) *pi/2))
          triangle <- polyfun(i, list(x=c(-.56, .0, .56), y=c(0.32, -0.5, 0.32),    # Canvio coordenades y i valors de theta per a que la punta del triangle estigui a dalt
                                      theta= -c(4, 7, 5) *pi/3))
          polylistD[[i]] <- list(square=square, circle=circle, diamond=diamond,      # Canvio nom a polylistD i la converteixo en una llista
                                 triangle=triangle)
        }
     }

    
     drawbox <- function(x, y, sex, affected, status, col, polylist, polylistD,    # Afegeixo polylistD, id, age, number i adopted
                density, angle, boxw, boxh, id, age, number, adopted) {
       
        ###  Modifico tota la funció drawbox  ###
       
        # Es comprova quins valors d'affected per l'individu en qüestió són diferents de 0 
        a <- which(affected != 0)
        l <- length(a)
        
        # Si tots els valors són 0 es genera un símbol buit
        if (l == 0) {
            polygon(x + polylist[[sex]][[1]]$x *boxw,
                    y + polylist[[sex]][[1]]$y *boxh,
                    col=NA, border=1)
        }
        
        # Si només un dels valors és diferent de 0, es comprova quin és el seu valor i
        else if (l == 1) {
          
            # si és 1 es genera un símbol amb el color i textura que correspongui (afectat)
            if (affected[a] == 1) {
              polygon(x + polylist[[sex]][[1]]$x * boxw,
                      y + polylist[[sex]][[1]]$y * boxh,
                      col=col[a], border=1, density=density[a], angle=angle[a])
            }
          
            # si és 2 es genera un símbol amb un punt al mig del color que correspongui (portador)
            else if (affected[a] == 2) {
              polygon(x + polylist[[sex]][[1]]$x * boxw,
                      y + polylist[[sex]][[1]]$y * boxh,
                      col=NA, border=1)
                 
              midx <- x + mean(range(polylist[[sex]][[1]]$x*boxw))
              midy <- y + mean(range(polylist[[sex]][[1]]$y*boxh))
                
              points(midx, midy, pch=16, cex=symbolsize, col=col[a])
            }
          
            # si és 3 es genera un símbol amb una línia vertical al mig del color que correspongui (presimptomàtic)
            else if (affected[a] == 3) {
              polygon(x + polylist[[sex]][[1]]$x * boxw,
                      y + polylist[[sex]][[1]]$y * boxh,
                      col=NA, border=1)
              
              midx <- x + mean(range(polylist[[sex]][[1]]$x*boxw))
              supy <- y + min(range(polylist[[sex]][[1]]$y*boxh))
              infy <- y + max(range(polylist[[sex]][[1]]$y*boxh))
              
              segments(midx, supy, midx, infy, col = col[a], lwd = symbolsize*2, lend = 1)
            }
          
            # si és -1 es genera un símbol amb un interrogant al mig (no afegit a l'aplicació)
            else if (affected[a] == -1) {
              polygon(x + polylist[[sex]][[1]]$x * boxw,
                      y + polylist[[sex]][[1]]$y * boxh,
                      col=NA, border=1)
            
              midx <- x + mean(range(polylist[[sex]][[1]]$x*boxw))
              midy <- y + mean(range(polylist[[sex]][[1]]$y*boxh))
            
              points(midx, midy, pch="?", cex=symbolsize)
            }
        }
        
        # Si dos o més dels valors d'affected són diferents de 0
        else {
          
            # es llegeix cadascún d'aquests valors d'un en un. l determina el nombre de divisions del símbol
            for (i in 1:l) {
              pos <- a[i]
              
              # Si el valor és 1 es genera una fracció del símbol amb el color i la textura que correspongui (afectat)
              if (affected[pos] == 1) {
                polygon(x + polylistD[[l]][[sex]][[i]]$x * boxw,     
                        y + polylistD[[l]][[sex]][[i]]$y * boxh,    
                        col=col[pos], border=1, density=density[pos], angle=angle[pos]) 
              }
              
              # Si el valor és -1 es genera una fracció del símbol amb un interrogant (no afegit a l'aplicació)
              else if (affected[pos] == -1) {
                polygon(x + polylistD[[l]][[sex]][[i]]$x * boxw,     
                        y + polylistD[[l]][[sex]][[i]]$y * boxh,    
                        col=NA, border=1)                     
                
                # Condicionals per a introduir els ?
                if (sex == 1 | sex == 2) {
                  midx <- x + mean(range(polylistD[[l]][[sex]][[i]]$x*boxw))    
                  midy <- y + mean(range(polylistD[[l]][[sex]][[i]]$y*boxh))    
                }
                
                else if (sex == 3 | sex == 4) {
                  midx <- x + (mean(range(polylistD[[l]][[sex]][[i]]$x*boxw)) * 0.5)  
                  midy <- y + mean(range(polylistD[[l]][[sex]][[i]]$y*boxh))
                }
                points(midx, midy, pch="?", cex=symbolsize/(l*0.7))   
                
              }
            }
            
        }
       

        # Es dibuixa la ratlla diagonal per a indicar si un individu està mort
        if (status==1) segments(x- .6*boxw, y+1.1*boxh, 
                                x+ .6*boxw, y- .1*boxh)
       
        # Afegeixo aquest condicional per a indicar si es tracta d'un embaràs
        else if (status == 2) {
          #polygon(x + (polylist[[1]][[1]])$x * (boxw/3.3),
          #        y + (polylist[[1]][[1]])$y * (boxh/2.5) + boxh/3.3,
          #        col="white", border="white")
          points(x + boxw*0.02, y + mean(range(polylist[[sex]][[1]]$y*boxh)), pch="P", cex=symbolsize*0.8)
        }
       
        # Afegeixo aquest condicional per a indicar si es tracta de varies persones
        if (!is.null(number)) {
          if (number != 1) {
            points(x + boxw*0.02, y + mean(range(polylist[[sex]][[1]]$y*boxh)), pch=paste(number), cex=symbolsize*0.8)
          }
        }
       
        # Afegeixo fletxa al consultand
        if (!is.null(consultand)) {
          for (i in 1:length(consultand)){
            if (id == consultand[i])
              arrows(x - boxw, y + boxh*1.5, x - boxw*0.65, y + boxh*1.15, lwd = 2+(symbolsize*0.25), length = symbolsize/13, angle = 20)
          }
        }
       
        # Afegeixo l'edat
        if (!is.null(age)) {
          text(x + boxw*0.5, y + boxh*1.15, age, cex = cex, adj = c(0.5, 1))
        }
        
        # Afegeixo claudàtors si l'individu és adoptat
        if (!is.null(adopted)) {
          if (!is.na(adopted)) {
            if (adopted == "in" | adopted == "out") {
              segments(x - 0.6*boxw, y - 0.1*boxh, x - 0.6*boxw, y + 1.1*boxh)
              segments(x - 0.6*boxw, y - 0.1*boxh, x - 0.3*boxw, y - 0.1*boxh)
              segments(x - 0.6*boxw, y + 1.1*boxh, x - 0.3*boxw, y + 1.1*boxh)
              segments(x + 0.6*boxw, y - 0.1*boxh, x + 0.6*boxw, y + 1.1*boxh)
              segments(x + 0.6*boxw, y - 0.1*boxh, x + 0.3*boxw, y - 0.1*boxh)
              segments(x + 0.6*boxw, y + 1.1*boxh, x + 0.3*boxw, y + 1.1*boxh)
            }
          }
        }
       
     }


    sex <- as.numeric(x$sex)
    for (i in 1:maxlev) {
        for (j in seq_len(plist$n[i])) {
            k <- plist$nid[i,j]
            drawbox(plist$pos[i,j], i, sex[k], affected[k,],
                    status[k], col, polylist, polylistD, density, angle,     # Afegeixo polylistD
                    boxw, boxh, x$id[k], age[k], number[k], adopted[k])      # Afegeixo x$id[k], age[k], number[k] i adopted[k]
            
            # Afegeixo la informació sota el símbol
            if (!is.null(info)) {
              pos_x <- plist$pos[i,j]
              pos_y <- i + boxh + labh*dist_text
              for (c in 1:ncol(info)) {
                if (!is.na(info[k,c]) & info[k,c] != "") {
                  text(pos_x, pos_y, info[k,c], cex=cex, adj=c(0.5,1), ...)
                  pos_y <- pos_y + labh * cex * 1.5
                }
              }
            }
        }
    }
    
    
    
    maxcol <- ncol(plist$nid)  #all have the same size
    for(i in 1:maxlev) {
        tempy <- i + boxh/2
        if(any(plist$spouse[i,  ]>0)) {
            temp <- (1:maxcol)[plist$spouse[i,  ]>0]
            segments(plist$pos[i, temp] + boxw/2, rep(tempy, length(temp)), 
                     plist$pos[i, temp + 1] - boxw/2, rep(tempy, length(temp)))

            temp <- (1:maxcol)[plist$spouse[i,  ] ==2]
            if (length(temp)) { #double line for double marriage
                tempy <- tempy + boxh/10
                segments(plist$pos[i, temp] + boxw/2, rep(tempy, length(temp)), 
                       plist$pos[i, temp + 1] - boxw/2, rep(tempy, length(temp)))
                }
        }
    }
    for(i in 2:maxlev) {
        zed <- unique(plist$fam[i,  ])
        zed <- zed[zed > 0]  #list of family ids
        
        for(fam in zed) {
            
            who <- (plist$fam[i,] == fam)  #The kids of interest
            index <- plist$nid[i,who]
            
            xx <- plist$pos[i - 1, fam + 0:1]
            parentx <- mean(xx)   #midpoint of parents


            # Draw the uplines
            
            if (is.null(plist$twins)) target <- plist$pos[i,who]
            else {
                twin.to.left <-(c(0, plist$twins[i,who])[1:sum(who)])
                temp <- cumsum(twin.to.left ==0) #increment if no twin to the left
                # 5 sibs, middle 3 are triplets gives 1,2,2,2,3
                # twin, twin, singleton gives 1,1,2,2,3
                tcount <- table(temp)
                target <- rep(tapply(plist$pos[i,who], temp, mean), tcount)
                }
            yy <- rep(i, sum(who))
            
            
            # Afegeixo comprovació de si els individus són adoptats o no per a dibuixar la línia vertical
            # discontinua en els casos necessaris
            if (!is.null(adopted)) {
              line_type <- c()
              p <- c()
              for (j in 1:length(index)) {
                ad <- adopted[index[j]]
                p[j] <- which(cumsum(who) == j)[1]
                if (!is.na(ad)) {
                  if (ad == "in") line_type[j] <- 2
                  else if (ad == "out") line_type[j] <- 1
                }
                else line_type[j] <- 1
              }
              segments(plist$pos[i,p], yy, target, yy - legh, lty = line_type)
            }
            else segments(plist$pos[i,who], yy, target, yy-legh)
            
                      
            ## draw midpoint MZ twin line
            if (any(plist$twins[i,who] ==1)) {
              who2 <- which(plist$twins[i,who] ==1)
              temp1 <- (plist$pos[i, who][who2] + target[who2])/2
              temp2 <- (plist$pos[i, who][who2+1] + target[who2])/2
                yy <- rep(i, length(who2)) - legh/2
                segments(temp1, yy, temp2, yy)
                }

            # Add a question mark for those of unknown zygosity
            if (any(plist$twins[i,who] ==3)) {
              who2 <- which(plist$twins[i,who] ==3)
              temp1 <- (plist$pos[i, who][who2] + target[who2])/2
              temp2 <- (plist$pos[i, who][who2+1] + target[who2])/2
                yy <- rep(i, length(who2)) - legh/2
                text((temp1+temp2)/2, yy, '?', cex = symbolsize * 0.75)       # Afegeixo cex = symbolsize * 0.75 per a que la mida de l'interrogant canviï amb la mida dels símbols
                }
            
            
            # Afegeixo comprovació per que la línia fins als pares sigui discontinua si tots els descendents són adoptats
            if (!is.null(adopted)) {
              if (!any(is.na(adopted[index]))) {
                if (all(adopted[index] == "in")) line_type2 <- 2
                else line_type2 <- 1
              }
              else line_type2 <- 1
            }
            else line_type2 <- 1
            
            
            # Add the horizontal line 
            segments(min(target), i-legh, max(target), i-legh, lty = line_type2)     # Afegeixo lty = line_type2

            # Draw line to parents.  The original rule corresponded to
            #  pconnect a large number, forcing the bottom of each parent-child
            #  line to be at the center of the bar uniting the children.
            if (diff(range(target)) < 2*pconnect) x1 <- mean(range(target))
            else x1 <- pmax(min(target)+ pconnect, pmin(max(target)-pconnect, 
                                                        parentx))
            y1 <- i-legh
            if(branch == 0)
                segments(x1, y1, parentx, (i-1) + boxh/2, lty = line_type2)    # Afegeixo lty = line_type2
            else {
                y2 <- (i-1) + boxh/2
                x2 <- parentx
                ydelta <- ((y2 - y1) * branch)/2
                segments(c(x1, x1, x2), c(y1, y1 + ydelta, y2 - ydelta), 
                         c(x1, x2, x2), c(y1 + ydelta, y2 - ydelta, y2), lty = line_type2)    # Afegeixo lty = line_type2
                }
            }
        }
    arcconnect <- function(x, y) {
        xx <- seq(x[1], x[2], length = 15)
        yy <- seq(y[1], y[2], length = 15) + (seq(-7, 7))^2/98 - .5
        lines(xx, yy, lty = 2)
        }

    uid <- unique(plist$nid)
    ## JPS 4/27/17: unique above only applies to rows
    ## unique added to for loop iterator
    for (id in unique(uid[uid>0])) {
        indx <- which(plist$nid == id)
        if (length(indx) >1) {   #subject is a multiple
            tx <- plist$pos[indx]
            ty <- ((row(plist$pos))[indx])[order(tx)]
            tx <- sort(tx)
            for (j in 1:(length(indx) -1))
                arcconnect(tx[j + 0:1], ty[j+  0:1])
            }
        }
    ckall <- x$id[is.na(match(x$id,x$id[plist$nid]))]
    if(length(ckall>0)) cat('Did not plot the following people:',ckall,'\n')
        
    if(!keep.par) par(oldpar)

    tmp <- match(1:length(x$id), plist$nid)
    invisible(list(plist=plist, x=plist$pos[tmp], y= row(plist$pos)[tmp],
                   boxw=boxw, boxh=boxh, call=Call))
    
    

}











