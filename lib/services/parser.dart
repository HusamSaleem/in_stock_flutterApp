

// Amazon: https://amazon.com/dp/itemID
// Returns -1 if invalid
// Amazon id is 10 in length
String parseAmazonLink(String amazonLink) {
  int dpIndex = amazonLink.indexOf('dp/');
  if (dpIndex == -1 && amazonLink.length != 10) {
    return "-1";
  }

  if (dpIndex == -1) {
    return amazonLink;
  }

  dpIndex += 3;
  int nextSlashIndex = amazonLink.indexOf('/', dpIndex);

  if (nextSlashIndex == -1) {
    return (amazonLink.substring(dpIndex).length == 10)
        ? amazonLink.substring(dpIndex)
        : "-1";
  } else {
    return (amazonLink.substring(dpIndex, nextSlashIndex + 1).length == 10)
        ? amazonLink.substring(dpIndex, nextSlashIndex + 1)
        : "-1";
  }
}
