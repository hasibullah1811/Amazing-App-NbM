const {Storage} = require('@google-cloud/storage');

const storage = new Storage(
    {  
      projectId: "amazing-app-nbm",
      credentials :{
        "client_email": "firebase-adminsdk-1aykz@amazing-app-nbm.iam.gserviceaccount.com",
        "private_key": "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC91bhcwdsuzlP8\nTSAHgrvDKbTmGlKku5V40Pq9Nk20iTK93vu0Rfdj8i2LT5k2/T04DX45T/k3wLJ9\nxt1jlb0rFjglxDBs1iLxEK7uqsV8L/s790cdOFOPUqJcjc4yk6Ad3VN5MBtYaxXL\n8HkPRVFTcyn8a8DNBWuGWXPdr58cL0ZD6uh8C/371rnS1Rhvo8f1au77MvWkRWSJ\nCiaQel6c7WBeVQjB3gWbERd7DA+BNpjOnDPQBKdn08dLy2E5o9tWKHuBH4pcTWsG\ndkVSVzdjDPMa2WXYpJwrR0q/jBvWg+o/2hhSeHIRhSCR+Mw3qpeUG3Cwnd3IIlpP\ncLf04MhBAgMBAAECggEABFJFiYAEuSyrewR28JDUbSGJi4zpGXSnNwo70PuX2n6e\ni/Wz4WNP2cO5L3ELDfZHEtv0xgF47QDbF1Oj9cjCdwUBF3P/PbUEs9vjPY3f4780\nXwW2pdbCyTISfdyhB2P2qsNfa3RxxOogI4W4fcVgT+/g0m0SBSDE1Ti7U140dyfe\ntplTCW+XGXKiWDOMb/G1Yn2QrorPtaFWcXTFB4I3+e4yVFnmWwWHOn3vMK7iZ3Wt\nJ8SdKnPenrRbfFJkORgDUukB2jdJIpxcRzNVA6Sl0N3Orn/7dqMRiA/3A0Ypmhil\nqtWLnJuRUbKXZX+uo0s95470qhlXwV6M3lCsVJXeCQKBgQD8hoSpv56EktWSIZxw\n87dGFD9mJLg4awhXbVFpSF4mPCi9I5jO0ayzeVPIxw8nTzIsivoYk67oD7i/NxnP\ngDg5uWXpMqxCQjvpxA9SiUT/pAe/F7Vn7055ozWzrTEFQK2Qiiq7Z5PBRJvyNAO0\nhymTltC0sUpT8T6akhxKgTImyQKBgQDAcmJL539232MhEjaBxu3jVV7l44sa1tzm\n4LLt1qoBDjje78tQEPHPDOJRywiKBA7/zbNR/CFl7gqnhvnupWkSTMLIqgQc5hjR\nGwB9dfgp4ym+se0Q37M9YqPR7lraI5jqqzPdrJg21fpYle1Y5m1gbaAmqAwHf0e/\nrUdGhQA5uQKBgHtLOm6ezkiwYHJO0tEbTXp73FCE0SVKrPHyv/MFkGJesQ1X2f3w\nxb+DF3NKLY3lzvuMh3uEb7uCIZPK1WFImysj6Cwpv41CRXpnbYvA1d1zOw0ECGBM\nqSYel9O4VdzYrWWK8D473hpY40MoPj7gV15mHlR6022UthpGCGYgGlpxAoGBALvc\n7Wf7jMqWN0bJaLw3XXJWnFT+U4TXyrz3DLRwoXR2Vb4LiAWZBPSCN0xxTtysKZg9\nTZfy8Qd34J65fLIidveOR3drwKgVVpSKL2hKCP+a6d1mA249cdOyvwjoDXh014n9\nppv3KIAfUku30ALArnU7juMtmNCYx4mtta55l0bBAoGAH5WBIlbDdYy5DbICnelv\nCHpDnbUd4UKhGxxohbroL7hvu8S/CygfdQ2dQYF7uzEGqaVu8j5HfmobV9+rK0u3\neh0zfxCswjhFb19sNLn+dYDmWW7fiaQDPLRjVE2aO/1XL840AHCrYUT37KLt4VLp\nTYPfqMlf0Fy7X4w0NThgO4U=\n-----END PRIVATE KEY-----\n"
      }
    }
  );
  
  
  const bucket = storage.bucket("gs://amazing-app-nbm.appspot.com");

/**
 * Upload the image file to Google Storage
 * @param {File} file object that will be uploaded to Google Storage
 */
 const uploadImageToStorage = (file, filename) => {
    return new Promise((resolve, reject) => {
      if (!file) {
        reject('No image file');
      }
      let newFileName = filename;
  
      let fileUpload = bucket.file(newFileName);
  
      const blobStream = fileUpload.createWriteStream({
        metadata: {
          contentType: file.mimetype
        }
      });
  
      blobStream.on('error', (error) => {
        console.log(error);
        reject('Something is wrong! Unable to upload at the moment.');
      });
  
      blobStream.on('finish', () => {
        // The public URL can be used to directly access the file via HTTP.
         const url = `https://storage.googleapis.com/${bucket.name}/${fileUpload.name}`;
         resolve(url);
      });
  
      blobStream.end(file.buffer);
    });
  }

  exports.uploadImageToStorage = uploadImageToStorage; 