package main

//导入包
import (
	"encoding/json"
	"fmt"
	"github.com/hyperledger/fabric/core/chaincode/shim"
	pb "github.com/hyperledger/fabric/protos/peer"
	"strconv"
	"sort"
	"crypto/sha256"
	"reflect"
	"bytes"
)

//全局变量
const (
	//invoke
	NotFoundFuncErrStr = "没有找到此方法："
	UndefinedFunStr    = "函数未定义！"
	//通用
	TxTimestampErrStr = "获取当前时间失败！"
	PutStateErrStr    = "上链失败！"
	GetStateErrStr    = "从链上获取数据失败！"
	//AddRecord
	AddRecordParameterErrStr         = "参数不正确，期望2个参数，您输入的参数个数为"
	StringToInt64ErrStr              = "creationDate转int64失败!"
	InvalidCreationDateStr           = "CreationDate只能为正数。"
	UnmarshalCourtFileInfoCertErrStr = "将字符串解析为CourtFileInfoCert异常，"
	MarshalCourtFileInfoCertErrStr   = "序列化CourtFileInfoCert失败！"
	CreateCourtFileInfoCertErrStr    = "根据输入信息创建卷宗异常！"
	ParentBizIdFormatErrStr          = "ParentBizId格式错误，必须包含'-'字符。"
	FileStatusErrStr                 = "添加记录文件状态只能是未归档，状态码为0"
	//GetRecord
	GetRecordParameterErrStr     = "参数不正确，期望3个参数，您输入的参数个数为"
	courtFileInfoCertNotFoundStr = "该文件不存在！"
	//AddEvent
	AddEventParameterErrStr        = "参数不正确，期望1参数，您输入的参数个数为"
	JsonMarshalEventErrStr         = "序列化Event失败！"
	JsonMarshalEventMetadataErrStr = "序列化EventMetadata失败!"
	timeStampStrToInt64ErrStr      = "timeStampStr转int64失败!"
	InvalidTimeStampStr            = "timeStampStr只能为正数。"
	//SearchEvent
	SearchEventParameterErrStr = "参数不正确，期望3个参数，您输入的参数个数为"
	EventResultsNextErrStr     = "对eventResults进行遍历异常!"
	MarshalsearchResErrStr     = "将searchRes转为byte失败!"
	//Archive
	ArchiveParameterErrStr = "参数不正确，期望3个参数，您输入的参数个数为"
	//Search
	SearchParameterErrStr    = "参数不正确，期望3个参数，您输入的参数个数为"
	PageSizeParaFormatErrStr = "pageSize参数格式不正确，必须是小于100的正整数！"
	QueryErrStr              = "根据queryString获取数据失败！"
	QueryResultsErrStr       = "遍历queryResults异常！"
	//OriginalFileKeyIdSearch
	OriginalFileKeyIdSearchParameterErrStr = "参数不正确，期望1个参数，您输入的参数个数为"
	GetOriginalFileErrStr                  = "根据KeyId获取原始文件失败！"
	OriginalFileKeyIdSplitLen              = "originalFileKeyId格式不符合要求"
	SplitCompositeKeyErrStr                = "CompositeKey分割异常！"
	InvalidCompositeKey                    = "无效的CompositeKey！"
	originalFileResultsNextErrStr          = "对originalFileResults进行遍历异常！"
	//GetAttestation
	GetAttestationParameterErrStr = "参数不正确，期望3个参数，您输入的参数个数为"
)

//智能合约
type CourtFileCertChaincode struct {
}

//文件数据结构
type CourtFileInfoCert struct {
	ObjectType            string            `json:"objectType"`            //docType类型
	ExternalId            string            `json:"externalId"`            //文件外部Id
	BizId                 string            `json:"bizId"`                 //文件的key
	FileHash              string            `json:"fileHash"`              //文件哈希
	FileName              string            `json:"fileName"`              //文件名称
	ParentBizId           string            `json:"parentBizId"`           //关联文件哈希
	AccountId             string            `json:"accountId"`             //链上调用者
	TxHash                string            `json:"txHash"`                //事务哈希
	FileDescription       string            `json:"fileDescription"`       //文件存证描述
	DeriveFileFlag        string            `json:"deriveFileFlag"`        //判断是否是衍生文件
	FileStorageStatus     string            `json:"fileStorageStatus"`     //卷宗存储状态
	OwnershipMetadata     OwnershipMetadata `json:"ownershipMetadata"`     //文件owner元数据
	OwnershipMetadataHash string            `json:"ownershipMetadataHash"` //文件owner元数据哈希
	FileMetadata          FileMetadata      `json:"fileMetadata"`          //	文件元数据
	FileMetadataHash      string            `json:"fileMetadataHash"`      //	文件元数据哈希
	StorageMetadata       StorageMetadata   `json:"storageMetadata"`       //	文件存储元数据
	StorageMetadataHash   string            `json:"storageMetadataHash"`   //	文件存储元数据哈希
	Timestamp             int64             `json:"timestamp"`             //	链上记录该条记录的时间戳
}

//文件所属结构
type OwnershipMetadata struct {
	Operator     string `json:"operator"`     //操作者
	Owner        string `json:"owner"`        //卷宗所有人
	Organization string `json:"organization"` //卷宗所属组织机构
}

//文件元数据
type FileMetadata struct {
	FileExtension string `json:"fileExtension"` //文件扩展名
	FileMimeType  string `json:"fileMimeType"`  //文件MIME类型
	FileSize      string `json:"fileSize"`      //文件大小
}

//文件存储结构
type StorageMetadata struct {
	StorageType          string       `json:"storageType"`          //文件存储类型,当前文件的存储类型
	FileId               string       `json:"fileId"`               //文件在分布式系统上的ID
	FileUri              string       `json:"fileUri"`              //文件资源标识符
	FilePublicUrl        string       `json:"filePublicUrl"`        //文件资源定位符
	FileStorageTimestamp int64        `json:"fileStorageTimestamp"` //dfs文件系统上的时间戳
	ArchiveLogs          []ArchiveLog `json:"archiveLogs"`          //归档记录
}

//文件存储结构签名时，ArchiveLogs的整体字符串拼接方法
func (s *StorageMetadata) PrintArchiveLogs() string {
	//拼接格式
	resultFormat := "ArchiveLogs=[%s]"
	//如果为空直接返回
	if nil == s || nil == s.ArchiveLogs {
		return fmt.Sprintf(resultFormat, "")
	}
	len := len(s.ArchiveLogs)
	if len < 1 {
		return fmt.Sprintf(resultFormat, "")
	}
	//循环数组内容，遍历拼接
	var buffer bytes.Buffer
	for i := 0; i < len; i++ {
		if 0 != i {
			buffer.WriteString("&")
		}
		buffer.WriteString(s.ArchiveLogs[i].Print())
	}
	//返回结果
	return fmt.Sprintf(resultFormat, buffer.String())
}

//归档结构体
type ArchiveLog struct {
	ArchiveTimestamp int64  `json:"archiveTimestamp"` //归档事件
	ArchiveLocation  string `json:"archiveLocation"`  //归档位置
}

//归档结构体签名时，字符串的拼接
func (a *ArchiveLog) Print() string {
	if nil == a {
		return ""
	}
	return fmt.Sprintf("ArchiveLocation=%s&ArchiveTimestamp=%+v", a.ArchiveLocation, a.ArchiveTimestamp)
}

//定义事件类型
const (
	CREATE_COURT_FILE = "1" //创建文件存证
	WATERMARK         = "2" //打水印
	UPLOAD_DFS        = "3" //上传文件到dfs
	ADD_RECORD        = "4" //添加文件存证
	ARCHIVE           = "5" //归档事件
	LOOK_UP           = "6" //查看事件
	COMMENTS          = "7" //备注事件
	CUSTOMIZE         = "8" //自定义事件

)

//存证类型
const (
	EventObjectType       = "Event"             //事件存证
	CourtFileInfoCertType = "CourtFileInfoCert" //人家存证
)

//文件存证对应的文件存储位置
const (
	DFS_STORAGE     = "1" //dfs存储
	ARCHIVE_STORAGE = "2" //归档存储
)

//事件存证结构
type CourtFileInfoCertEvent struct {
	ObjectType        string        `json:"objectType"`        //docType类型
	BizId             string        `json:"bizId"`             //事件存证Id
	AccountId         string        `json:"accountId"`         //上下文AccountId（被register和enroll过的链上用户）
	EventType         string        `json:"eventType"`         //事件类型
	FileName          string        `json:"fileName"`          //事件存证对应的文件
	Description       string        `json:"description"`       //事件描述
	TxHash            string        `json:"txHash"`            //事务哈希
	Timestamp         int64         `json:"timestamp"`         //	链上记录该条记录的时间戳
	EventMetadata     EventMetadata `json:"eventMetadata"`     //事件元数据
	EventMetadataHash string        `json:"eventMetadataHash"` //事件元数据哈希
	ExternalTimestamp int64         `json:"externalTimestamp"` //链下实际发生时间
	Operator          string        `json:"operator"`          //操作者
}

//事件元数据结构
type EventMetadata struct {
	Source          string `json:"source"`          //文件来源
	DerivedFileName string `json:"derivedFileName"` //产生水印后的新文件名
	StorageType     string `json:"storageType"`     //存储方式
	Content         string `json:"content"`         //自定义事件存证内容，json或者其他由用户自己决定
	FileId          string `json:"fileId"`          //在DFS系统的Id
	FileUri         string `json:"fileUri"`         //文件资源标识符
	FilePublicUrl   string `json:"filePublicUrl"`   //文件资源定位符
	ArchiveLocation string `json:"archiveLocation"` //归档位置
	FileBizId       string `json:"fileBizId"`       //事件存证对应文件存证的BizId
	FileHash        string `json:"fileHash"`        //事件存证对应的文件hash
	FileDescription string `json:"fileDescription"` //文件备注
	Ip              string `json:"ip"`              //卷宗查阅或评论者的IP
	UserAgent       string `json:"userAgent"`       //卷宗查阅或评论者请求端的User-Agent
	Comment         string `json:"comment"`         //给卷宗添加备注时，被添加的备注
}

//分页response数据结构
type ResponseMetadata struct {
	RecordsCount int32  `json:"recordsCount"` //每次查几条数据
	Bookmark     string `json:"bookMark"`     //标记从哪里开始查询
}

//文件存证查询结果结构
type CourtFileInfoCertSearchRes struct {
	CourtFileInfoCerts []CourtFileInfoCert `json:"courtFileInfoCerts"` //查询到的文件数组
	ResponseMetadata   ResponseMetadata    `json:"responseMetadata"`   //分页查询返回值
}

//事件存证查询结果结构
type CourtFileInfoCertEventSearchRes struct {
	CourtFileInfoCertEvents []CourtFileInfoCertEvent `json:"courtFileInfoCertEvents"` //查询到的文件数组
	ResponseMetadata        ResponseMetadata         `json:"responseMetadata"`        //分页查询返回值
}

//主方法
func main() {
	//主函数中启动智能合约
	err := shim.Start(new(CourtFileCertChaincode))
	if err != nil {
		fmt.Printf("Error starting CourtFileCertChaincode: %s", err)
	}
}

// 初始化方法
func (t *CourtFileCertChaincode) Init(stub shim.ChaincodeStubInterface) pb.Response {
	fmt.Print("chaincode initial...")
	return shim.Success(nil)
}

// 方法调用中心代理，多个实际的方法调用转发
func (t *CourtFileCertChaincode) Invoke(stub shim.ChaincodeStubInterface) pb.Response {
	//获取合约方法名称和参数
	function, args := stub.GetFunctionAndParameters()
	//判断哪个方法被调用
	if function == "AddRecord" { //调用AddRecord方法
		return t.AddRecord(stub, args)
	} else if function == "GetRecord" { //调用GetRecord方法
		return t.GetRecord(stub, args)
	} else if function == "AddEvent" { //调用AddEvent方法
		return t.AddEvent(stub, args)
	} else if function == "GetEvent" { //调用GetEvent方法
		return t.GetEvent(stub, args)
	} else if function == "Archive" { //调用Archive方法
		return t.Archive(stub, args)
	} else if function == "SearchRecord" { //文件存证富查询
		return t.SearchRecord(stub, args)
	} else if function == "SearchEvent" { //事件存证富查询
		return t.SearchEvent(stub, args)
	}
	return shim.Error(UndefinedFunStr) //调用错误处理
}

// ===== AddRecord  ========================================================
//  文件存证上链
//	@param	courtFileInfoCertJson
//	@return bizId
//	根据入参构造CourtFileInfoCert对象，并按照key-value的形式存入couchdb
// ======================================================================================
func (t *CourtFileCertChaincode) AddRecord(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//校验参数个数是否正确
	if len(args) != 2 {
		return shim.Error(AddRecordParameterErrStr + string(len(args)))
	}
	//获取入参
	courtFileInfoCertJson := args[0]
	//第二个参数 operator
	operator := args[1]
	//定义CourtFileInfoCert类型变量
	var courtFileInfoCert CourtFileInfoCert
	//将courtFileInfoCertJson解析为CourtFileInfoCert结构体
	err := json.Unmarshal([]byte(courtFileInfoCertJson), &courtFileInfoCert)
	//解析异常处理
	if err != nil {
		return shim.Error(UnmarshalCourtFileInfoCertErrStr)
	}
	//获取当前链上时间
	timestamp, err := stub.GetTxTimestamp()

	//设置ObjectType
	courtFileInfoCert.ObjectType = CourtFileInfoCertType
	//设置上链时间
	courtFileInfoCert.Timestamp = timestamp.Seconds
	//设置txHash
	courtFileInfoCert.TxHash = stub.GetTxID()
	//设置文件存证内容hash值
	courtFileInfoCert.OwnershipMetadataHash = defaultSign(&courtFileInfoCert.OwnershipMetadata)
	courtFileInfoCert.FileMetadataHash = defaultSign(&courtFileInfoCert.FileMetadata)
	courtFileInfoCert.StorageMetadataHash = defaultSign(&courtFileInfoCert.StorageMetadata)
	//序列化courtFileInfoCert
	courtFileInfoCertBytes, err := json.Marshal(courtFileInfoCert)
	//序列化异常处理
	if err != nil {
		return shim.Error(MarshalCourtFileInfoCertErrStr + err.Error())
	}
	fmt.Println("文件存证字符串：" + string(courtFileInfoCertBytes))
	//存入couchdb
	stub.PutState(courtFileInfoCert.BizId, courtFileInfoCertBytes)
	//添加事件存证
	var Event CourtFileInfoCertEvent
	//添加事件存证文档类型
	Event.ObjectType = EventObjectType
	//事件存证的操作者
	Event.Operator = operator

	//获取时间失败处理
	if err != nil {
		return shim.Error(TxTimestampErrStr + err.Error())
	}
	//添加事件存证AccountId
	Event.AccountId = courtFileInfoCert.AccountId
	//添加事件存证类型
	Event.EventType = ADD_RECORD
	//添加事件存证链下实际发生的时间戳
	Event.ExternalTimestamp = timestamp.Seconds
	//添加事件存证对应的文件存证的名称
	Event.FileName = courtFileInfoCert.FileName
	//添加文件hash
	Event.EventMetadata.FileHash = courtFileInfoCert.FileHash
	//添加事件存证关联的文件存证bizId
	Event.EventMetadata.FileBizId = courtFileInfoCert.BizId
	//添加事件存证对应的文件存证的存储位置
	Event.EventMetadata.Source = courtFileInfoCert.StorageMetadata.FilePublicUrl
	// 添加事件描述 Event.Description
	Event.Description = "文件存证上链"

	//序列化事件存证
	EventBytes, err := json.Marshal(Event)
	//序列化事件存证异常处理
	if err != nil {
		return shim.Error(JsonMarshalEventErrStr + err.Error())
	}
	EventJson := string(EventBytes)
	//为addRecord 添加事件存证
	fmt.Println("EventJson字符串：" + EventJson)
	t.AddEvent(stub, []string{EventJson})
	//返回文件存证的bizId
	return shim.Success([]byte(courtFileInfoCert.BizId ))
}

// ===== GetRecord ========================================================
//  根据keyId获取存证信息
//	@param	bizId operator
//	@return bool
//	根据keyId从couchdb中获取存证信息并返回
// =======================================================================
func (t *CourtFileCertChaincode) GetRecord(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//校验参数
	if len(args) != 3 {
		return shim.Error(GetRecordParameterErrStr + string(len(args)))
	}
	bizId := args[0]    //第一个参数keyId
	operator := args[1] //第二个参数 operator
	ip := args[2]       //第3个参数，调用者的ip地址
	var courtFileInfoCert CourtFileInfoCert
	//根据bizId获取文件存证
	courtFileInfoCertBytes, err := stub.GetState(bizId)
	//将存证信息转为CourtFileInfoCert结构体
	json.Unmarshal(courtFileInfoCertBytes, &courtFileInfoCert)
	//添加查看事件存证
	var Event CourtFileInfoCertEvent
	//添加事件存证文档类型
	Event.ObjectType = EventObjectType
	//添加事件存证操作者
	Event.Operator = operator
	//为事件存证添加访问者IP
	Event.EventMetadata.Ip = ip
	//获取当前链上时间
	timestamp, err := stub.GetTxTimestamp()
	//获取时间异常处理
	if err != nil {
		return shim.Error(TxTimestampErrStr + err.Error())
	}
	//添加事件存证AccountId
	Event.AccountId = courtFileInfoCert.AccountId
	//添加事件存证类型
	Event.EventType = LOOK_UP
	//添加事件存证类型外部时间
	Event.ExternalTimestamp = timestamp.Seconds
	//添加事件存证对应的文件存证的名称
	Event.FileName = courtFileInfoCert.FileName
	//添加事件存证对应的文件存证的存储位置
	Event.EventMetadata.Source = courtFileInfoCert.StorageMetadata.FilePublicUrl
	//序列化Event
	EventBytes, err := json.Marshal(Event)
	//序列化Event异常处理
	if err != nil {
		return shim.Error(JsonMarshalEventErrStr + err.Error())
	}
	EventJson := string(EventBytes)
	fmt.Println("GetRecord 事件存证字符串：" + EventJson)
	//为GetRecord添加事件存证
	t.AddEvent(stub, []string{EventJson})
	fmt.Println("GetRecord 文件存证字符串：" + string(courtFileInfoCertBytes))
	//返回存证信息
	return shim.Success(courtFileInfoCertBytes)
}

// ===== AddEvent ========================================================
//	为某个存证添加事件记录信息，这样我们可以清晰的看到对这个文件的一系列操作
//	@param	EventJson
//	@return txHash
//	按照Event-bizId-eventName-operator-timestamp的格式为事件创建compositeKey
//  并存入couchdb数据库
//	方便后期对Event进行查询
// =======================================================================
func (t *CourtFileCertChaincode) AddEvent(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//参数校验
	if len(args) != 1 {
		return shim.Error(AddEventParameterErrStr + string(len(args)))
	}
	//第一个参数EventJson
	EventJson := args[0]
	//构建eventBizId
	txHash := stub.GetTxID()
	//定义CourtFileInfoCertEvent类型变量
	var Event CourtFileInfoCertEvent
	//将EventJson解析为结构体
	json.Unmarshal([]byte(EventJson), &Event)
	Event.ObjectType = EventObjectType
	if Event.BizId == "" {
		Event.BizId = "Event-Internal-" + txHash
	}
	//获取当前链上时间
	timestamp, err := stub.GetTxTimestamp()
	//获取时间失败处理
	if err != nil {
		return shim.Error(TxTimestampErrStr + err.Error())
	}
	//存证上链时间
	Event.Timestamp = timestamp.Seconds
	//添加事件存证的事务哈希
	Event.TxHash = stub.GetTxID()
	//设置meta hash
	Event.EventMetadataHash = defaultSign(&Event.EventMetadata)
	EventBytes, err := json.Marshal(Event)
	//事件存证序列化异常处理
	if err != nil {
		return shim.Error(JsonMarshalEventErrStr + err.Error())
	}
	fmt.Println("AddEvent 事件存证字符串" + string(EventBytes))
	//将事件存证存入couchdb
	stub.PutState(Event.BizId, EventBytes)
	//返回事件存证的BizId
	return shim.Success([]byte(Event.BizId))
}

// ===== GetEvent ========================================================
//  根据keyId获取存证信息
//	@param	bizId operator
//	@return bool
//	根据keyId从couchdb中获取存证信息并返回
// =======================================================================
func (t *CourtFileCertChaincode) GetEvent(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//校验参数
	if len(args) != 1 {
		return shim.Error(GetRecordParameterErrStr + string(len(args)))
	}
	eventBizId := args[0] //第一个参数keyId
	//根据bizId获取事件存证
	courtFileInfoCertEventBytes, err := stub.GetState(eventBizId)
	if err != nil {
		return shim.Error(GetStateErrStr)
	}
	fmt.Println("GetEvent 事件存证字符串：" + string(courtFileInfoCertEventBytes))
	//返回存证信息
	return shim.Success(courtFileInfoCertEventBytes)
}

// ===== SearchRecord ========================================================
//  根据queryString进行分页富查询
//	@param	queryString	pageSize bookmark
//	@return searchRes
//	根据queryString进行复查询，返回查询结果
// =========================================================================================
func (t *CourtFileCertChaincode) SearchRecord(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//参数校验
	if len(args) != 3 {
		return shim.Error(SearchParameterErrStr + string(len(args)))
	}
	//第一个参数 根据需要拼出的queryString
	//例：queryString := fmt.Sprintf("{\"selector\":{\"$and\":[{\"externalId\":\"%s\"},{\"fileUri\":\"%s\"}]}}", externalId, fileUri)
	queryString := args[0]                             //富查询字符串，由调用端自行拼装后传入
	pageSize, err := strconv.ParseInt(args[1], 10, 32) //第二个参数 pageSize
	//对pageSize进行校验
	if err != nil {
		return shim.Error(PageSizeParaFormatErrStr + err.Error())
	}
	//pageSize的值不能为0和负数，不能大于100，重置pageSize为10 ，查询10条记录
	if pageSize <= 0 || pageSize >= 100 {
		pageSize = 10
	}
	bookmark := args[2] //第三个参数 pageSize
	//用queryString进行查询
	queryResults, queryMetadata, err := stub.GetQueryResultWithPagination(queryString, int32(pageSize), bookmark)
	//查询异常处理
	if err != nil {
		return shim.Error(QueryErrStr + err.Error())
	}
	//对查询结果进行校验
	if queryResults != nil {
		defer queryResults.Close()
		var courtFileInfoCertArr []CourtFileInfoCert
		var newFile CourtFileInfoCert
		//遍历查询结果
		for queryResults.HasNext() {
			file, err := queryResults.Next()
			if err != nil {
				return shim.Error(QueryResultsErrStr + err.Error())
			}
			//将结果中的元素转为CourtFileInfoCert结构体
			json.Unmarshal([]byte(file.Value), &newFile)
			json.Marshal(newFile)
			//将遍历的元素加入courtFileInfoCertArr数组
			courtFileInfoCertArr = append(courtFileInfoCertArr, newFile)
		}
		//创建searchRes变量并赋值
		var courtFileInfoCertSearchRes CourtFileInfoCertSearchRes
		courtFileInfoCertSearchRes.CourtFileInfoCerts = courtFileInfoCertArr
		courtFileInfoCertSearchRes.ResponseMetadata.Bookmark = queryMetadata.Bookmark
		courtFileInfoCertSearchRes.ResponseMetadata.RecordsCount = queryMetadata.FetchedRecordsCount
		//序列化
		searchResByte, err := json.Marshal(courtFileInfoCertSearchRes)
		//序列化异常处理
		if err != nil {
			return shim.Error(MarshalsearchResErrStr + err.Error())
		}
		//将查询结果返回
		return shim.Success(searchResByte)
	}
	return shim.Success([]byte(""))
}

// ===== SearchEvent ========================================================
//  根据queryString进行分页富查询
//	@param	queryString	pageSize bookmark
//	@return searchRes
//	根据queryString进行复查询，返回查询结果
// =========================================================================================
func (t *CourtFileCertChaincode) SearchEvent(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//参数校验
	if len(args) != 3 {
		return shim.Error(SearchParameterErrStr + string(len(args)))
	}
	//第一个参数 根据需要拼出的queryString
	queryString := args[0]                             //第一个参数，富查询字符串，由业务端封装传入
	pageSize, err := strconv.ParseInt(args[1], 10, 32) //第二个参数 pageSize
	//对pageSize进行校验
	if err != nil {
		return shim.Error(PageSizeParaFormatErrStr + err.Error())
	}
	//pageSize的值不能为0和负数，不能大于100，重置pageSize为10 ，查询10条记录
	if pageSize <= 0 || pageSize >= 100 {
		pageSize = 10
	}
	bookmark := args[2] //第三个参数 pageSize
	//用queryString进行查询
	queryResults, queryMetadata, err := stub.GetQueryResultWithPagination(queryString, int32(pageSize), bookmark)
	//查询异常处理
	if err != nil {
		return shim.Error(QueryErrStr + err.Error())
	}
	//对查询结果进行校验
	if queryResults != nil {
		defer queryResults.Close()
		var courtFileInfoCertEventsArr []CourtFileInfoCertEvent
		var event CourtFileInfoCertEvent
		//遍历查询结果
		for queryResults.HasNext() {
			file, err := queryResults.Next()
			if err != nil {
				return shim.Error(QueryResultsErrStr + err.Error())
			}
			//将结果中的元素转为courtFileInfoCertEvent结构体
			json.Unmarshal([]byte(file.Value), &event)
			json.Marshal(event)
			//将遍历的元素加入courtFileInfoCertEventArr数组
			courtFileInfoCertEventsArr = append(courtFileInfoCertEventsArr, event)
		}
		//创建searchRes变量并赋值
		var courtFileInfoCertEventSearchRes CourtFileInfoCertEventSearchRes
		courtFileInfoCertEventSearchRes.CourtFileInfoCertEvents = courtFileInfoCertEventsArr
		courtFileInfoCertEventSearchRes.ResponseMetadata.Bookmark = queryMetadata.Bookmark
		courtFileInfoCertEventSearchRes.ResponseMetadata.RecordsCount = queryMetadata.FetchedRecordsCount
		//序列化
		searchResByte, err := json.Marshal(courtFileInfoCertEventSearchRes)
		//序列化异常处理
		if err != nil {
			return shim.Error(MarshalsearchResErrStr + err.Error())
		}
		//将查询结果返回
		return shim.Success(searchResByte)
	}
	return shim.Success([]byte(""))
}

// ===== Archive ========================================================
//  对文件存证进行归档
//	@param	bizId	archiveLocation
//	@return txID

// =========================================================================================
func (t *CourtFileCertChaincode) Archive(stub shim.ChaincodeStubInterface, args []string) pb.Response {
	//参数校验
	if len(args) != 4 {
		return shim.Error(ArchiveParameterErrStr + string(len(args)))
	}
	//第一个参数keyId
	bizId := args[0]
	//第二个参数，archiveLocation 归档位置
	archiveLocation := args[1]
	//第三个参数 operator
	operator := args[2]
	//第四个参数，执行archive的账户（一般这里应该是System账户）
	accountId := args[3]
	//根据bizId获取文件存证
	courtFileInfoCertBytes, err := stub.GetState(bizId)
	//获取存证异常处理
	if err != nil {
		return shim.Error(GetStateErrStr + err.Error())
	}
	//定义CourtFileInfoCert类型变量
	var courtFileInfoCert CourtFileInfoCert
	//将文件存证信息解析为CourtFileInfoCert类型
	json.Unmarshal(courtFileInfoCertBytes, &courtFileInfoCert)
	//构建ArchiveLog
	var archiveLog ArchiveLog
	//将归档位置写入归档日志中
	archiveLog.ArchiveLocation = archiveLocation
	//获取当前时间
	timestamp, err := stub.GetTxTimestamp()
	//获取时间异常处理
	if err != nil {
		return shim.Error(TxTimestampErrStr + err.Error())
	}
	//把文档类型标记为归档
	courtFileInfoCert.StorageMetadata.StorageType = ARCHIVE_STORAGE
	//将归档时间写入归档日志中
	archiveLog.ArchiveTimestamp = timestamp.Seconds
	//将本次归档操作记录到ArchiveLogs中
	courtFileInfoCert.StorageMetadata.ArchiveLogs = append(courtFileInfoCert.StorageMetadata.ArchiveLogs, archiveLog)
	//归档变动了StorageMetadata,需要重新计算hash值
	courtFileInfoCert.StorageMetadataHash = defaultSign(&courtFileInfoCert.StorageMetadata)
	//序列化文件存证信息
	courtFileInfoCertArchivedBytes, err := json.Marshal(courtFileInfoCert)
	if err != nil {
		return shim.Error(MarshalCourtFileInfoCertErrStr + err.Error())
	}
	//存入couchdb
	stub.PutState(bizId, courtFileInfoCertArchivedBytes)

	//交易提案时指定的交易ID
	txID := stub.GetTxID()
	//添加Archive事件记录信息
	// 添加事件存证
	var Event CourtFileInfoCertEvent
	//添加事件存证AccountId
	Event.AccountId = accountId
	Event.Operator = operator
	//添加事件存证类型
	Event.EventType = ARCHIVE
	//添加事件存证链下实际发生的时间戳
	Event.ExternalTimestamp = timestamp.Seconds
	//添加事件存证对应的文件存证的名称
	Event.FileName = courtFileInfoCert.FileName
	//添加事件的文件hash
	Event.EventMetadata.FileHash = courtFileInfoCert.FileHash
	//添加事件存证关联的文件存证bizId
	Event.EventMetadata.FileBizId = bizId
	//添加事件存证对应文件存证的存储类型
	Event.EventMetadata.StorageType = courtFileInfoCert.StorageMetadata.StorageType
	// 添加事件描述 Event.Description
	Event.Description = "归档文件"
	//序列化事件存证
	EventBytes, err := json.Marshal(Event)
	//序列化事件存证异常处理
	if err != nil {
		return shim.Error(JsonMarshalEventErrStr + err.Error())
	}
	EventJson := string(EventBytes)
	t.AddEvent(stub, []string{EventJson})
	//返回txID
	return shim.Success([]byte(txID))
}

/**
	* 默认的hash签名方法
 */
func defaultSign(structName interface{}) string {
	//拼接待签名的对象
	beforeSign := contractObject(structName)
	fmt.Println("签名前的字符串：", beforeSign)
	//使用sha256对内容进行摘要
	signBytes := sha256.Sum256([]byte(beforeSign))
	//结果变成16进制字符串
	sign := fmt.Sprintf("%x", signBytes)
	fmt.Println("签名后16进制字符串：", sign)
	return sign
}

/**
  反射调用，把结构体内容，按key的字母序升序排列，然后串联成key=value&key=value形式返回
  注意：1. 只支持第一层对象是简单类型int,string等,
            2. 如果第一层属性是数组类型，第一层需要自己实现Print+{属性名}方法，参考：func (s *StorageMetadata) PrintArchiveLogs() string
            3. 其他类型，需要自己实现
 */
func contractObject(structName interface{}) string {
	//对象
	object := reflect.ValueOf(structName)
	//结构体的值
	values := object.Elem()
	//结构体类型
	objectType := values.Type()

	//字段长度
	filedNum := values.NumField()
	//名字数组
	names := make([]string, filedNum)
	//初始化名字数组
	for i := 0; i < filedNum; i++ {
		names[i] = objectType.Field(i).Name
	}
	//名字字母序排序
	sort.Strings(names)
	//拼接成key=value&key=value形式
	var buffer bytes.Buffer
	for i := 0; i < filedNum; i++ {
		if i != 0 {
			buffer.WriteString("&")
		}
		name := names[i]
		val := values.FieldByName(names[i])

		if val.Kind() == reflect.Slice {
			//数组类型，需要自己实现打印方法，方法名Print+{属性名},参考：func (s *StorageMetadata) PrintArchiveLogs() string
			pr := object.MethodByName("Print" + name).Call([]reflect.Value{})
			buffer.WriteString(pr[0].String())
		} else { //其他类型
			buffer.WriteString(fmt.Sprintf("%s%s%+v", names[i], "=", val))
		}
	}
	beforeSign := buffer.String()
	fmt.Println("签名前的字符串：", beforeSign)
	return beforeSign
}

