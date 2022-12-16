const express = require("express");
const auth = require("../routes/authentication");
const profilepic = require("../routes/profilepic");
const home = require("../routes/home");
const getProfile = require("../routes/getProfile");
const fs = require("firebase-admin");
const { initializeApp } = require("firebase/app");

const firebaseConfig = {
  apiKey: "AIzaSyCLV8L-ZwkzWEbfRZGu3DArBvJFzbNUsQM",
  authDomain: "amazing-app-nbm.firebaseapp.com",
  projectId: "amazing-app-nbm",
  storageBucket: "amazing-app-nbm.appspot.com",
  messagingSenderId: "925629464605",
  appId: "1:925629464605:web:0ba353995bb9ad9de686f4",
  measurementId: "G-5FL823Y0H4",
};

const serviceAccount = {
  type: "service_account",
  project_id: "amazing-app-nbm",
  private_key_id: "858fbc4d7a4826689a4aa16577f5ffdb2c58622a",
  private_key:
    "-----BEGIN PRIVATE KEY-----\nMIIEvQIBADANBgkqhkiG9w0BAQEFAASCBKcwggSjAgEAAoIBAQC91bhcwdsuzlP8\nTSAHgrvDKbTmGlKku5V40Pq9Nk20iTK93vu0Rfdj8i2LT5k2/T04DX45T/k3wLJ9\nxt1jlb0rFjglxDBs1iLxEK7uqsV8L/s790cdOFOPUqJcjc4yk6Ad3VN5MBtYaxXL\n8HkPRVFTcyn8a8DNBWuGWXPdr58cL0ZD6uh8C/371rnS1Rhvo8f1au77MvWkRWSJ\nCiaQel6c7WBeVQjB3gWbERd7DA+BNpjOnDPQBKdn08dLy2E5o9tWKHuBH4pcTWsG\ndkVSVzdjDPMa2WXYpJwrR0q/jBvWg+o/2hhSeHIRhSCR+Mw3qpeUG3Cwnd3IIlpP\ncLf04MhBAgMBAAECggEABFJFiYAEuSyrewR28JDUbSGJi4zpGXSnNwo70PuX2n6e\ni/Wz4WNP2cO5L3ELDfZHEtv0xgF47QDbF1Oj9cjCdwUBF3P/PbUEs9vjPY3f4780\nXwW2pdbCyTISfdyhB2P2qsNfa3RxxOogI4W4fcVgT+/g0m0SBSDE1Ti7U140dyfe\ntplTCW+XGXKiWDOMb/G1Yn2QrorPtaFWcXTFB4I3+e4yVFnmWwWHOn3vMK7iZ3Wt\nJ8SdKnPenrRbfFJkORgDUukB2jdJIpxcRzNVA6Sl0N3Orn/7dqMRiA/3A0Ypmhil\nqtWLnJuRUbKXZX+uo0s95470qhlXwV6M3lCsVJXeCQKBgQD8hoSpv56EktWSIZxw\n87dGFD9mJLg4awhXbVFpSF4mPCi9I5jO0ayzeVPIxw8nTzIsivoYk67oD7i/NxnP\ngDg5uWXpMqxCQjvpxA9SiUT/pAe/F7Vn7055ozWzrTEFQK2Qiiq7Z5PBRJvyNAO0\nhymTltC0sUpT8T6akhxKgTImyQKBgQDAcmJL539232MhEjaBxu3jVV7l44sa1tzm\n4LLt1qoBDjje78tQEPHPDOJRywiKBA7/zbNR/CFl7gqnhvnupWkSTMLIqgQc5hjR\nGwB9dfgp4ym+se0Q37M9YqPR7lraI5jqqzPdrJg21fpYle1Y5m1gbaAmqAwHf0e/\nrUdGhQA5uQKBgHtLOm6ezkiwYHJO0tEbTXp73FCE0SVKrPHyv/MFkGJesQ1X2f3w\nxb+DF3NKLY3lzvuMh3uEb7uCIZPK1WFImysj6Cwpv41CRXpnbYvA1d1zOw0ECGBM\nqSYel9O4VdzYrWWK8D473hpY40MoPj7gV15mHlR6022UthpGCGYgGlpxAoGBALvc\n7Wf7jMqWN0bJaLw3XXJWnFT+U4TXyrz3DLRwoXR2Vb4LiAWZBPSCN0xxTtysKZg9\nTZfy8Qd34J65fLIidveOR3drwKgVVpSKL2hKCP+a6d1mA249cdOyvwjoDXh014n9\nppv3KIAfUku30ALArnU7juMtmNCYx4mtta55l0bBAoGAH5WBIlbDdYy5DbICnelv\nCHpDnbUd4UKhGxxohbroL7hvu8S/CygfdQ2dQYF7uzEGqaVu8j5HfmobV9+rK0u3\neh0zfxCswjhFb19sNLn+dYDmWW7fiaQDPLRjVE2aO/1XL840AHCrYUT37KLt4VLp\nTYPfqMlf0Fy7X4w0NThgO4U=\n-----END PRIVATE KEY-----\n",
  client_email:
    "firebase-adminsdk-1aykz@amazing-app-nbm.iam.gserviceaccount.com",
  client_id: "107112963066733370320",
  auth_uri: "https://accounts.google.com/o/oauth2/auth",
  token_uri: "https://oauth2.googleapis.com/token",
  auth_provider_x509_cert_url: "https://www.googleapis.com/oauth2/v1/certs",
  client_x509_cert_url:
    "https://www.googleapis.com/robot/v1/metadata/x509/firebase-adminsdk-1aykz%40amazing-app-nbm.iam.gserviceaccount.com",
};

// Initialize Firebase-admin
fs.initializeApp({
  credential: fs.credential.cert(serviceAccount),
});

// Initialize Firebase
const app = initializeApp(firebaseConfig);

module.exports = function (app) {
  app.use(express.json());
  app.use("/api/auth", auth);
  app.use("/api/upload", profilepic);
  app.use("/api", home);
  app.use("/api/getProfile/", getProfile);
};
