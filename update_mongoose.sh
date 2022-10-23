echo "If there is an error try again or git reset."
rm -f src/mongoose.c src/mongoose.h
curl https://raw.githubusercontent.com/cesanta/mongoose/master/mongoose.c -o main/mongoose.c
curl https://raw.githubusercontent.com/cesanta/mongoose/master/mongoose.h -o main/mongoose.h
