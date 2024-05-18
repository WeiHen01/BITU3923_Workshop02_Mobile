import 'forum.dart';
import 'user.dart';

/**
 * This is the Forum Post class for temporary
 */
class ForumPost{
  int postId = 0;
  String postTitle = "";
  String postDesc = "";
  String postDate = "";
  String postTime = "";

  // foreign keys
  User user;
  Forum forum;

  /**
   * constructor
   */
  ForumPost(this.postId, this.user, this.forum, this.postTitle, this.postDesc,
      this.postDate, this.postTime);

  /**
   * mapping to JSON body
   * for getting response from JSON
   */
  ForumPost.fromJson(Map<String, dynamic> json):
        postId = json["postId"],
        user = User.fromJson(json["userId"]),
        forum = Forum.fromJson(json["forumId"]),
        postTitle = json["postTitle"],
        postDesc = json["postDesc"],
        postDate = json["postDate"],
        postTime = json["postTime"];

  /**
   * getters and setters
   */
  int get _postId => postId;
  set _postId(int value) => postId = value;

  User get _user => user;
  set _user(User value) => user = value;

  Forum get _forum => forum;
  set _forum(Forum value) => forum = value;

  String get _postTitle => postTitle;
  set _postTitle(String value) => postTitle = value;

  String get _postDesc => postDesc;
  set _postDesc(String value) => postDesc = value;

  String get _postDate => postDate;
  set _postDate(String value) => postDate = value;

  String get _postTime => postTime;
  set _postTime(String value) => postTime = value;

}