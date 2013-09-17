func_comment = __F 'comment'
pagedown = require("pagedown")
safeConverter = pagedown.getSanitizingConverter()
moment = require 'moment'
module.exports.controllers = 
  "/:target_id":
    get:(req,res,next)->
      result = 
        success:0
      func_comment.getAll 1,20,{target_id:req.params.target_id},(error,comments)->
        if error
          result.info = error.message
        else
          result.success = 1
          comments.forEach (comment)->
            comment.createdAt = moment(comment.createdAt).fromNow()
          result.comments = comments
        res.send result
  "/add":
    get:(req,res,next)->

    post:(req,res,next)->
      result = 
        success:0
      req.body.html = safeConverter.makeHtml req.body.md
      req.body.user_id = res.locals.user.id
      req.body.user_headpic = res.locals.user.head_pic
      req.body.user_nick = res.locals.user.nick

      func_comment.add req.body,(error,comment)->
        if error 
          result.info = error.message
        else
          result.success = 1
          comment.createdAt = moment(comment.createdAt).format("LLL")
          result.comment = comment
          (__F 'coin').add 1,res.locals.user.id,"添加了评论"
          if match = req.body.target_id.match(/^article_([0-9]*)$/)
            (__F 'article').addComment(match[1])
          else if match = req.body.target_id.match(/^card_([0-9]*)$/)
            (__F 'card').addComment(match[1])
          else if match = req.body.target_id.match(/^act_([0-9]*)$/)
            (__F 'act').addCount(match[1],"comment_count")
        res.send result

module.exports.filters = 
  "/add":
    post:['checkLoginJson']