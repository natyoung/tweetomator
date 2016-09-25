#!/bin/bash

echo "Creating heroku dyno..."
heroku create --stack cedar

echo "Enter your Twitter API credentials..."
read -p "Consumer key: " consumer_key
read -p "Consumer secret: " consumer_secret
read -p "Access token: " access_token
read -p "Access token secret: " access_token_secret
read -p "Twitter username: " username

echo "Enter your Flickr API credentials..."
read -p "API key: " flickr_api_key
read -p "Shared secret: " flickr_shared_secret

echo "Path to input text file..."
read -p "Path: " markov_chain_input_file

heroku config:add TWITTER_CONSUMER_KEY=${consumer_key} \
    TWITTER_CONSUMER_SECRET=${consumer_secret} \
    TWITTER_ACCESS_TOKEN=${access_token} \
    TWITTER_ACCESS_TOKEN_SECRET=${access_token_secret} \
    TWITTER_USERNAME=${username} \
    FLICKR_API_KEY=${flickr_api_key} \
    FLICKR_SHARED_SECRET=${flickr_shared_secret} \
    MARKOV_CHAIN_INPUT_TEXT_FILE=${markov_chain_input_file}

git push heroku master
heroku ps:scale web=1

echo "done."
