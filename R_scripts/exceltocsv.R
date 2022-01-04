library("rio")
dt_path <- './Datasets_ori'
file_list <- list.files(path = dt_path)
for (i in 1:6) { #因为有五个文件
  file <- file_list[i]
  file_name <- paste('./Datasets/', substring(file, 1, 7), '.csv', sep = '')
  file <- paste(dt_path, "/", file, sep = '')
  rio::convert(file, file_name, out_opts = list(format = 'csv'))
}


