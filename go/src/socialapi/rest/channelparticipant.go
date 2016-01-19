package rest

import (
	"encoding/json"
	"fmt"
	"socialapi/models"

	"gopkg.in/mgo.v2/bson"
)

func CreateChannelParticipants(channelId, accountId int64, token string, c int) ([]*models.ChannelParticipant, error) {
	var participants []*models.ChannelParticipant
	for i := 0; i < c; i++ {
		participant, err := CreateChannelParticipant(channelId, accountId, token)
		if err != nil {
			return nil, err
		}

		participants = append(participants, participant)
	}

	return participants, nil
}

func CreateChannelParticipant(channelId, requesterId int64, token string) (*models.ChannelParticipant, error) {
	account := models.NewAccount()
	account.OldId = bson.NewObjectId().Hex()
	account, _ = CreateAccount(account)
	return AddChannelParticipant(channelId, requesterId, token, account.Id)
}

func ListChannelParticipants(channelId, accountId int64, token string) ([]models.ChannelParticipantContainer, error) {

	url := fmt.Sprintf("/channel/%d/participants?accountId=%d", channelId, accountId)
	// res, err := sendRequest("GET", url, nil)
	res, err := sendRequestWithAuth("GET", url, nil, token)
	if err != nil {
		return nil, err
	}
	var participants []models.ChannelParticipantContainer
	err = json.Unmarshal(res, &participants)
	if err != nil {
		return nil, err
	}

	return participants, nil
}

func AddChannelParticipant(channelId, requesterId int64, token string, accountIds ...int64) (*models.ChannelParticipant, error) {
	url := fmt.Sprintf("/channel/%d/participants/add?accountId=%d", channelId, requesterId)
	return channelParticipantOp(
		url,
		channelId,
		requesterId,
		token,
		accountIds...,
	)
}

func DeleteChannelParticipant(channelId int64, requesterId int64, token string, accountIds ...int64) (*models.ChannelParticipant, error) {
	url := fmt.Sprintf("/channel/%d/participants/remove?accountId=%d", channelId, requesterId)
	return channelParticipantOp(
		url,
		channelId,
		requesterId,
		token,
		accountIds...,
	)
}

func BlockChannelParticipant(channelId int64, requesterId int64, token string, accountIds ...int64) (*models.ChannelParticipant, error) {
	url := fmt.Sprintf("/channel/%d/participants/block?accountId=%d", channelId, requesterId)
	return channelParticipantOp(
		url,
		channelId,
		requesterId,
		token,
		accountIds...,
	)
}

func UnblockChannelParticipant(channelId, requesterId int64, token string, accountIds ...int64) (*models.ChannelParticipant, error) {
	url := fmt.Sprintf("/channel/%d/participants/unblock?accountId=%d", channelId, requesterId)
	return channelParticipantOp(
		url,
		channelId,
		requesterId,
		token,
		accountIds...,
	)
}

func AcceptInvitation(channelId int64, token string) error {
	url := fmt.Sprintf("/channel/%d/invitation/accept", channelId)
	cp := models.NewChannelParticipant()
	_, err := marshallAndSendRequestWithAuth("POST", url, cp, token)

	return err
}

func RejectInvitation(channelId int64, token string) error {
	url := fmt.Sprintf("/channel/%d/invitation/reject", channelId)
	cp := models.NewChannelParticipant()
	_, err := marshallAndSendRequestWithAuth("POST", url, cp, token)

	return err
}

func InviteChannelParticipant(channelId, requesterId int64, token string, accountIds ...int64) (*models.ChannelParticipant, error) {
	url := fmt.Sprintf("/channel/%d/participants/add?accountId=%d", channelId, requesterId)

	res := make([]*models.ChannelParticipant, 0)
	for _, accountId := range accountIds {
		c := models.NewChannelParticipant()
		c.AccountId = accountId
		c.StatusConstant = models.ChannelParticipant_STATUS_REQUEST_PENDING
		res = append(res, c)
	}

	// cps, err := sendModel("POST", url, &res)
	cps, err := sendModelWithAuth("POST", url, &res, token)
	if err != nil {
		return nil, err
	}

	a := *(cps.(*[]*models.ChannelParticipant))

	return a[0], nil
}

func channelParticipantOp(url string, channelId, requesterId int64, token string, accountIds ...int64) (*models.ChannelParticipant, error) {

	res := make([]*models.ChannelParticipant, 0)
	for _, accountId := range accountIds {
		c := models.NewChannelParticipant()
		c.AccountId = accountId
		res = append(res, c)
	}

	// cps, err := sendModel("POST", url, &res)
	cps, err := sendModelWithAuth("POST", url, &res, token)
	if err != nil {
		return nil, err
	}

	a := *(cps.(*[]*models.ChannelParticipant))

	return a[0], nil
}
