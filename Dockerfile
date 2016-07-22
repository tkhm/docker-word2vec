FROM centos:centos7
MAINTAINER Naoya Murakami <naoya@createfield.com>

RUN localedef -f UTF-8 -i ja_JP ja_JP.utf8
ENV LANG ja_JP.UTF-8
ENV LANGUAGE ja_JP:ja
ENV LC_ALL ja_JP.UTF-8

RUN yum install -y wget tar vi
RUN yum install -y gcc make gcc-c++
RUN yum install -y git patch
RUN yum install -y icu libicu-devel
RUN yum install -y epel-release
RUN yum install -y re2 re2-devel
RUN yum install -y wordnet wordnet-devel glib2 glib2-devel
RUN yum install -y gflags gflags-devel

# Mecab
RUN wget http://mecab.googlecode.com/files/mecab-0.996.tar.gz
RUN tar -xzf mecab-0.996.tar.gz
RUN cd mecab-0.996; ./configure --enable-utf8-only; make; make install; ldconfig
RUN echo "/usr/local/lib" > /etc/ld.so.conf.d/mecab.conf
RUN ldconfig

# Ipadic
RUN wget http://mecab.googlecode.com/files/mecab-ipadic-2.7.0-20070801.tar.gz
RUN tar -xzf mecab-ipadic-2.7.0-20070801.tar.gz
RUN cd mecab-ipadic-2.7.0-20070801; ./configure --with-charset=utf8; make; make install
RUN echo "dicdir = /usr/local/lib/mecab/dic/ipadic" > /usr/local/etc/mecabrc

# word2vec multiple threads patch
RUN wget http://www.chokkan.org/software/word2vec-multi/word2vec.local.tgz
RUN tar -xzf word2vec.local.tgz

# word2vec
RUN git clone https://github.com/svn2github/word2vec.git
RUN cd word2vec ; make ; \
    cp word2vec /usr/local/bin ; cp word2phrase /usr/local/bin ; \
    cp word-analogy /usr/local/bin ; cp distance /usr/local/bin ; \
    cp compute-accuracy /usr/local/bin ; cp demo-analogy.sh /usr/local/bin ; \
    cp demo-classes.sh /usr/local/bin ; cp demo-phrase-accuracy.sh /usr/local/bin ; \
    cp demo-phrases.sh /usr/local/bin ; cp demo-word-accuracy.sh /usr/local/bin ; \
    cp demo-word.sh /usr/local/bin ; cp questions-phrases.txt /usr/local/bin ; \
    cp questions-words.txt /usr/local/bin ;

# word2vec-calc
RUN git clone https://github.com/naoa/word2vec-calc.git
RUN cd word2vec-calc ; make ; cp word2vec-calc /usr/local/bin

# string-splitter
RUN git clone https://github.com/naoa/string-splitter.git
RUN cd string-splitter ; make ; cp string-splitter /usr/local/bin

VOLUME ["/var/lib/word2vec"]

# Clean up
RUN rm -rf mecab-0.996.tar.gz*
RUN rm -rf mecab-ipadic-2.7.0-20070801.tar.gz*
RUN rm -rf word2vec.local.tgz*

# Additional description for Rosette
RUN mkdir -p /usr/local/BasisTech/BT_RLP_7.14.0
ENV BT_ROOT /usr/local/BasisTech/BT_RLP_7.14.0
ENV BT_BUILD amd64-glibc25-gcc41
ADD rlp-with-rws-7.14.0-sdk-amd64-glibc25-gcc41.tar.gz /usr/local/BasisTech/BT_RLP_7.14.0 
ADD rlp-license.xml /usr/local/BasisTech/BT_RLP_7.14.0/rlp/rlp/licenses/rlp-license.xml
ENV PATH $PATH:$BT_ROOT/rlp/bin/$BT_BUILD
