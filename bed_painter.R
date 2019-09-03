#!/usr/bin/env Rscript

# Add color to BED file

'usage: bed_painter.R (-i input) (-f factor) [-n name] [-e score] [-s strand] [-k keep] [-p palette] [-P paletteFile] [-o output]

options:
-i input        input BED, stdin for stdin
-f factor       column(s) that contains factor for coloring
-n name         name column [default: 4]
-e score        score column [default: 5]
-s strand       strand column [default: 6]
-k keep         additional columns to keep [default: NULL]
-p palette      vector of colors, interpolated if necessary, or color palette [default: rainbow]
-P paletteFile  a list of colors
-o output       merged states in BED
' -> doc;

opt <- handle_args(doc);

opt$f <- eval(parse(text=opt$f));
opt$n <- as.integer(opt$n);
opt$e <- as.integer(opt$e);
opt$s <- as.integer(opt$s);
opt$k <- eval(parse(text=opt$k));

# docopt strips quotes, e.g. "red" becomes red (bareword), so has to provide an environment for eval()
colorspace <- as.list(colors());
names(colorspace) <- colors();
opt$p <- eval(parse(text=opt$p), envir=colorspace);
if (!is.null(opt$P)) opt$p <- read.tsv(opt$P, comment='')[,1];
if (is.vector(opt$p)) opt$p <- colorRampPalette(opt$p);

if (is.null(opt$o)) opt$o <- stdout();

if (opt$i=='stdin') {
    dat <- read.bed(opt$i, header=F);
} else {
    dat <- read.bed(opt$i);
}
nr <- nrow(dat);
nc <- ncol(dat);

# Get feature id
n <- which(colnames(dat)=='name'|colnames(dat)=='id');
n <- ifelse(length(n)==0,opt$n, n);
if (n>nc) { id <- paste(dat[,1], paste(dat[,2], dat[,3], sep='-'), sep=':'); } else { id <- dat[,n]; }

# Get feature score
e <- which(colnames(dat)=='score');
e <- ifelse(length(e)==0,opt$e, e);
if (e>nc) { score <- rep(0, nr); } else { score <- dat[,e]; }

# Get feature strand
s <- which(colnames(dat)=='strand');
s <- ifelse(length(s)==0,opt$s, s);
if (s>nc) { strand <- rep('.', nr); } else { strand <- dat[,s]; }

# Get feature color
if (length(opt$f)>1) {
    f <- apply(dat[,opt$f,drop=F], 1, paste, collapse=',');
} else {
    f <- dat[,opt$f];
}
l <- length(unique(f));
colors <- apply(col2rgb((opt$p)(l)), 2, paste, collapse=',');
itemRgb <- colors[as.integer(as.factor(f))];

# Get additional columns
extra <- dat[,opt$k[opt$k<=nc]];

output <- data.frame(dat[,1:3],id=id,score=score,strand=strand,dat[,2:3],itemRgb,extra);

tryCatch(write.tsv(output, opt$o, col.names=F, row.names=F),
         error=function(cond) { if (cond$message=='ignoring SIGPIPE signal') {} else stop(cond) },
         warning=function(cond) { message(warning) },
         finally={});
